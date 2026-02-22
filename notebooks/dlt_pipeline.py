
# Databricks notebook source

import dlt
from pyspark.sql.functions import *

@dlt.table(
  name="numbers_table"
)
def numbers_table():
    return spark.range(10)

@dlt.table(
  name="doubled_numbers"
)
def doubled_numbers():
    df = dlt.read("numbers_table")
    return df.withColumn("double_value", col("id") * 2)