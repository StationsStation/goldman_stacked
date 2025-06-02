# Chatroom Protocol

## Description

...

## Specification

```yaml
name: chatroom
author: eightballer
version: 0.1.0
description: A protocol for sending and receiving messages to and from a chatroom.
license: Apache-2.0
aea_version: '>=1.0.0, <2.0.0'
protocol_specification_id: eightballer/chatroom:0.1.0
speech_acts:
  message:
    chat_id: pt:str
    text: pt:str
    id: pt:optional[pt:int]
    parse_mode: pt:optional[pt:str]
    reply_markup: pt:optional[pt:str]
    from_user: pt:optional[pt:str]
    timestamp: pt:optional[pt:int]
  message_sent:
    id: pt:optional[pt:int]
  error:
    error_code: ct:ErrorCode
    error_msg: pt:str
    error_data: pt:dict[pt:str, pt:bytes]
  subscribe:
    chat_id: pt:str
  unsubscribe:
    chat_id: pt:str
  get_channels:
    agent_id: pt:str
  unsubscription_result:
    chat_id: pt:str
    status: pt:str
  subscription_result:
    chat_id: pt:str
    status: pt:str
  channels:
    channels: pt:list[pt:str]
---
ct:ErrorCode: |
  enum ErrorCodeEnum {
      UNKNOWN_CHAT_ID = 0;
      API_ERROR = 1;
      INVALID_MESSAGE_FORMAT = 2;
    }
  ErrorCodeEnum error_code = 1;
---
initiation: [message, subscribe, unsubscribe, get_channels]
reply:
  subscribe: [subscription_result,  error]
  unsubscribe: [unsubscription_result, error]
  message: [message_sent, error]
  get_channels: [channels, error]
  unsubscription_result: [ ]
  subscription_result: [ ]
  channels: [ ]
  message_sent: [ ]
  error: [ ]
termination: [unsubscription_result, subscription_result, message_sent, error, channels]
roles: { agent }
end_states: [unsubscription_result, subscription_result, message_sent, error, channels]
keep_terminal_state_dialogues: false

```