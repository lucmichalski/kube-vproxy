/**
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
package org.apache.hama.bsp.message;

import org.apache.hadoop.io.Writable;
import org.apache.hama.bsp.BSPMessageBundle;

public interface MessageEventListener<M extends Writable> {

  /**
   * 
   *
   */
  public static enum MessageManagerEvent {
    INITIALIZED, MESSAGE_SENT, MESSAGE_RECEIVED, CLOSE
  }

  /**
   * The function to handle the event when the queue is initialized.
   */
  void onInitialized();

  /**
   * The function to handle the event when a message is sent.
   * <code>message</code> should not be modified.
   * 
   * @param peerName Name of the peer to be sent.
   * @param message The message set.
   */
  void onMessageSent(String peerName, final M message);

  /**
   * The function to handle the event when a message is received.
   * <code>message</code> should not be modified.
   * 
   * @param message The message received.
   */
  void onMessageReceived(final M message);
  
  void onBundleReceived(final BSPMessageBundle<M> bundle);

  /**
   * The function to handle the event when the queue is closed.
   */
  void onClose();

}
