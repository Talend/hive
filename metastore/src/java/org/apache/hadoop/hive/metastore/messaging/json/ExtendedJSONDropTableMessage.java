/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.hive.metastore.messaging.json;


import org.apache.hadoop.hive.metastore.api.Table;
import org.codehaus.jackson.annotate.JsonProperty;


public class ExtendedJSONDropTableMessage extends JSONDropTableMessage {
  @JsonProperty
  private String location;
  @JsonProperty
  private String tableType;

  public ExtendedJSONDropTableMessage() {
  }

  @Deprecated
  public ExtendedJSONDropTableMessage(String server, String servicePrincipal, String db, String table, Long timestamp, String location) {
    super(server, servicePrincipal, db, table, timestamp);
    this.location = location;
  }

  public ExtendedJSONDropTableMessage(String server, String servicePrincipal, Table tableObj,
      Long timestamp, String location) {
    super(server, servicePrincipal, tableObj, timestamp);
    this.location = location;
    this.tableType = tableObj.getTableType();
  }

  public String getLocation() {
    return location;
  }

  public String getTableType() {
    return tableType;
  }

  @Override
  public String toString() {
    return ExtendedJSONMessageDeserializer.serialize(this);
  }
}
