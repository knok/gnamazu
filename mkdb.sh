#!/bin/sh
#

DBNAME=Namazu/NMZ.db

test -f $DBNAME && rm -f Namazu/NMZ.db*

groonga -n $DBNAME < /dev/null

groonga $DBNAME table_create --name Fields --flags TABLE_HASH_KEY \
    --key_type ShortText
groonga $DBNAME table_create --name Index --flags TABLE_PAT_KEY\|KEY_NORMALIZE \
    --key_type ShortText --default_tokenizer TokenBigram

groonga $DBNAME column_create --table Fields --name date --flags COLUMN_SCALAR --type Time
groonga $DBNAME column_create --table Fields --name from --flags COLUMN_SCALAR --type ShortText
groonga $DBNAME column_create --table Fields --name message_id --flags COLUMN_SCALAR --type ShortText
groonga $DBNAME column_create --table Fields --name newsgroups --flags COLUMN_SCALAR --type ShortText
groonga $DBNAME column_create --table Fields --name subject --flags COLUMN_SCALAR --type ShortText
groonga $DBNAME column_create --table Fields --name to --flags COLUMN_SCALAR --type ShortText
groonga $DBNAME column_create --table Fields --name url --flags COLUMN_SCALAR --type ShortText
groonga $DBNAME column_create --table Fields --name body --flags COLUMN_SCALAR --type Text

groonga $DBNAME column_create --table Index --name body \
    --flags COLUMN_INDEX\|WITH_SECTION\|WITH_POSITION --type Fields \
    --source body
#    --source body,from,message_id,subject,to,url
