/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hive.spark.client.metrics;

import java.io.Serializable;

import org.apache.spark.executor.TaskMetrics;

import org.apache.hadoop.hive.common.classification.InterfaceAudience;

/**
 * Metrics pertaining to reading input data.
 */
@InterfaceAudience.Private
public class InputMetrics implements Serializable {
  /** Total number of bytes read. */
  public final long bytesRead;
  /** Total number of EC bytes read. */
  public final long bytesReadEC;
  /** Total number of records read. */
  public final long recordsRead;

  private InputMetrics() {
    // For Serialization only.
    this(0L, 0L, 0L);
  }

  public InputMetrics(
      long bytesRead,
      long bytesReadEC,
      long recordsRead
      ) {
    this.bytesRead = bytesRead;
    this.bytesReadEC = bytesReadEC;
    this.recordsRead = recordsRead;
  }

  public InputMetrics(TaskMetrics metrics) {
    this(metrics.inputMetrics().bytesRead(),
      metrics.inputMetrics().bytesReadEC(),
      metrics.inputMetrics().recordsRead()
            );
  }

  @Override
  public String toString() {
    return "InputMetrics{" +
            "bytesRead=" + bytesRead +
            ", bytesReadEC=" + bytesReadEC +
            '}';
  }
}
