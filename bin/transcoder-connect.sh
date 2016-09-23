#!/usr/bin/expect -f

set timeout 2
set PASS "transcoder"

spawn ssh transcoder@172.20.0.10

expect {
  # "password:" {
    # send "$PASS\n"
    expect "$*"
    send "transcoder-view\n"
  }
}
interact
