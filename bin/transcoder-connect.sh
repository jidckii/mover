#!/usr/bin/expect -f

set timeout 2

spawn ssh transcoder@172.20.0.10

expect {
    "$*" {
    send "transcoder-view \n"
  }
}
interact
