#!/bin/bash

tr "abcdefhijklmnopqrstuvwxyzABCDEFHIJKLMNOPQRSTUVWXYZ" "olpzcaimsqxywrnedbhftvujkOLPZCAIMSQXYWRNEDBHFTVUJK" <TopSekret.txt >ReadableSekret.txt

./shift ReadableSekret.txt
