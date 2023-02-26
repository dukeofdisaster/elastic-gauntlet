# DEV TOOLS COMMANDS
## DELETE OPS
```
DELETE /my_index
DELETE /_data_stream/my_data_stream

```
## REINDEX OPS

```
#### good for legacy type indices; i.e. if we update a mapping and need to reindex or want to reduce shard sizing
POST _reindex
{
  "source": {
    "index": "mypattern-000001"
  },
  "dest": {
    "index": "mypattern-rollover"
  }
}

#### same functionality can be achieved on data streams but you just have to reindex the backing index into the parent with op_type of create
POST _reindex
{
  "source": {
    "index": ".ds-logs-mydata-default-2023.02.01-000001"
  },
  "dest": {
    "index": "logs-mydata-default",
    "op_type": "create"
  }
}

### reindex with pipeline
POST _reindex
{
  "source": {
    "index": "my_source_index"
  },
  "dest": {
    "index": "my_destination_index"
  },
  "pipeline": "my_ingest_pipeline"
}

#### reindex with script
POST _reindex
{
  "source": {
    "index": "my_source_index"
  },
  "dest": {
    "index": "my_destination_index"
  },
  "script": {
    "source": "ctx._source.field = 'new_value'"
  }
}
```
