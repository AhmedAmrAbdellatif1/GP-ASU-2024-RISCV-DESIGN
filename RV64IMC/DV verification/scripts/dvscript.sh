#!/bin/bash

cat "rasu.txt"
cat "hello.txt"

python3 rm_step1.py
python3 rm_step2.py
python3 rm_step3.py
python3 rm_step4.py
python3 mod_questa_log.py

cat "test.txt"

python3 compare-logs.py
