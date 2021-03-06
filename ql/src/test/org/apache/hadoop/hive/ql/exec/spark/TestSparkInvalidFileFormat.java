/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.hive.ql.exec.spark;

import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.hive.ql.CommandNeedRetryException;
import org.apache.hadoop.hive.ql.DriverFactory;
import org.apache.hadoop.hive.ql.IDriver;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.security.authorization.plugin.sqlstd.SQLStdHiveAuthorizerFactory;
import org.apache.hadoop.hive.ql.session.SessionState;

import org.junit.Assert;
import org.junit.Test;

import java.io.File;
import java.io.IOException;

public class TestSparkInvalidFileFormat {

  @Test
  public void readTextFileAsParquet() throws IOException, CommandNeedRetryException {
    HiveConf conf = new HiveConf();
    conf.setVar(HiveConf.ConfVars.HIVE_AUTHORIZATION_MANAGER,
            SQLStdHiveAuthorizerFactory.class.getName());
    conf.setBoolVar(HiveConf.ConfVars.HIVE_SUPPORT_CONCURRENCY, false);
    conf.setVar(HiveConf.ConfVars.HIVE_EXECUTION_ENGINE, "spark");
    conf.set("spark.master", "local");

    FileSystem fs = FileSystem.getLocal(conf);
    Path tmpDir = new Path("TestSparkInvalidFileFormat-tmp");

    File testFile = new File(conf.get("test.data.files"), "kv1.txt");

    SessionState.start(conf);

    IDriver driver = null;

    try {
      driver = DriverFactory.newDriver(conf);
      Assert.assertEquals(0,
              driver.run("CREATE TABLE test_table (key STRING, value STRING)").getResponseCode());
      Assert.assertEquals(0, driver.run(
              "LOAD DATA LOCAL INPATH '" + testFile + "' INTO TABLE test_table").getResponseCode());
      Assert.assertEquals(0,
              driver.run("ALTER TABLE test_table SET FILEFORMAT parquet").getResponseCode());
      Throwable exception = driver.run(
              "SELECT * FROM test_table ORDER BY key LIMIT 10").getException();
      Assert.assertTrue(exception instanceof HiveException);
      Assert.assertTrue(exception.getMessage().contains("Spark job failed due to task failures"));
      Assert.assertTrue(exception.getMessage().contains("kv1.txt is not a Parquet file. expected " +
              "magic number at tail [80, 65, 82, 49] but found [95, 57, 55, 10]"));
    } finally {
      if (driver != null) {
        Assert.assertEquals(0, driver.run("DROP TABLE IF EXISTS test_table").getResponseCode());
        driver.destroy();
      }
      if (fs.exists(tmpDir)) {
        fs.delete(tmpDir, true);
      }
    }
  }
}
