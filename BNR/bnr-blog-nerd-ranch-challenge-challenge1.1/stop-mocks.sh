#!/bin/sh

ps -ef | grep WireMock | grep -v grep | awk '{print $2}' | xargs kill
