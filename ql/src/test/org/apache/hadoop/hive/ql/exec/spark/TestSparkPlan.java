package org.apache.hadoop.hive.ql.exec.spark;

import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.hive.ql.Driver;
import org.apache.hadoop.hive.ql.exec.Utilities;
import org.apache.hadoop.hive.ql.io.HiveKey;
import org.apache.hadoop.hive.ql.security.authorization.plugin.sqlstd.SQLStdHiveAuthorizerFactory;
import org.apache.hadoop.hive.ql.session.SessionState;

import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.mapred.JobConf;

import org.apache.spark.Dependency;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;

import org.apache.spark.rdd.HadoopRDD;
import org.apache.spark.rdd.MapPartitionsRDD;
import org.apache.spark.rdd.RDD;
import org.apache.spark.rdd.ShuffledRDD;

import org.junit.Assert;
import org.junit.Test;

import scala.Tuple2;
import scala.collection.JavaConversions;

import java.io.File;
import java.nio.file.Paths;
import java.util.List;


public class TestSparkPlan {

  @Test
  public void testSetRDDCallSite() throws Exception {
    String confDir = "../data/conf/spark/local/hive-site.xml";
    HiveConf.setHiveSiteLocation(new File(confDir).toURI().toURL());
    HiveConf conf = new HiveConf();

    // Set to false because we don't launch a job using LocalHiveSparkClient so the
    // hive-kryo-registrator jar is never added to the classpath
    conf.setBoolVar(HiveConf.ConfVars.SPARK_OPTIMIZE_SHUFFLE_SERDE, false);
    conf.set("spark.local.dir", Paths.get(System.getProperty("test.tmp.dir"),
            "TestSparkPlan-local-dir").toString());

    FileSystem fs = FileSystem.getLocal(conf);
    Path tmpDir = new Path("TestSparkPlan-tmp");

    SessionState.start(conf);

    Driver driver = null;
    JavaSparkContext sc = null;

    try {
      driver = new Driver(conf);
      Assert.assertEquals(0, driver.run("create table test (col int)").getResponseCode());

      driver.compile("select * from test order by col");
      List<SparkTask> sparkTasks = Utilities.getSparkTasks(driver.getPlan().getRootTasks());
      Assert.assertEquals(1, sparkTasks.size());

      SparkTask sparkTask = sparkTasks.get(0);

      JobConf jobConf = new JobConf(conf);

      SparkConf sparkConf = new SparkConf();
      sparkConf.setMaster("local");
      sparkConf.setAppName("TestSparkPlan-app");
      sc = new JavaSparkContext(sparkConf);

      SparkPlanGenerator sparkPlanGenerator = new SparkPlanGenerator(sc, null, jobConf, tmpDir,
              null);
      SparkPlan sparkPlan = sparkPlanGenerator.generate(sparkTask.getWork());
      RDD<Tuple2<HiveKey, BytesWritable>> reducerRdd = sparkPlan.generateGraph().rdd();

      Assert.assertTrue(reducerRdd.name().contains("Reducer 2"));
      Assert.assertTrue(reducerRdd instanceof MapPartitionsRDD);
      Assert.assertTrue(reducerRdd.creationSite().shortForm().contains("Reducer 2"));
      Assert.assertTrue(reducerRdd.creationSite().longForm().contains("Explain Plan"));
      Assert.assertTrue(reducerRdd.creationSite().longForm().contains("Reducer 2"));

      List<Dependency<?>> rdds = JavaConversions.seqAsJavaList(reducerRdd.dependencies());
      Assert.assertEquals(1, rdds.size());
      RDD shuffledRdd = rdds.get(0).rdd();

      Assert.assertTrue(shuffledRdd.name().contains("Reducer 2"));
      Assert.assertTrue(shuffledRdd.name().contains("SORT"));
      Assert.assertTrue(shuffledRdd instanceof ShuffledRDD);
      Assert.assertTrue(shuffledRdd.creationSite().shortForm().contains("Reducer 2"));
      Assert.assertTrue(shuffledRdd.creationSite().longForm().contains("Explain Plan"));
      Assert.assertTrue(shuffledRdd.creationSite().longForm().contains("Reducer 2"));

      rdds = JavaConversions.seqAsJavaList(shuffledRdd.dependencies());
      Assert.assertEquals(1, rdds.size());
      RDD mapRdd = rdds.get(0).rdd();

      Assert.assertTrue(mapRdd.name().contains("Map 1"));
      Assert.assertTrue(mapRdd instanceof MapPartitionsRDD);
      Assert.assertTrue(mapRdd.creationSite().shortForm().contains("Map 1"));
      Assert.assertTrue(mapRdd.creationSite().longForm().contains("Explain Plan"));
      Assert.assertTrue(mapRdd.creationSite().longForm().contains("Map 1"));

      rdds = JavaConversions.seqAsJavaList(mapRdd.dependencies());
      Assert.assertEquals(1, rdds.size());
      RDD hadoopRdd = rdds.get(0).rdd();

      Assert.assertTrue(hadoopRdd.name().contains("Map 1"));
      Assert.assertTrue(hadoopRdd.name().contains("test"));
      Assert.assertTrue(hadoopRdd instanceof HadoopRDD);
      Assert.assertTrue(hadoopRdd.creationSite().shortForm().contains("Map 1"));
    } finally {
      if (driver != null) {
        Assert.assertEquals(0, driver.run("drop table if exists test").getResponseCode());
        driver.destroy();
      }
      if (sc != null) {
        sc.close();
      }
      if (fs.exists(tmpDir)) {
        fs.delete(tmpDir, true);
      }
    }
  }
}
