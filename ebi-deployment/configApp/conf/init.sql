create schema file_key_test;
create schema dev_ega_file;

CREATE TABLE file_key_test.key_format_cv (
	key_format varchar(128) NOT NULL,
	is_current bool NOT NULL DEFAULT false,
	CONSTRAINT key_format_cv_pkey PRIMARY KEY (key_format)
)
WITH (
	OIDS=FALSE
);

CREATE TABLE dev_ega_file.file_key (
	file_id  varchar(128) NULL,
	encryption_key_id int8 NULL,
    encryption_algorithm varchar(128) NULL
)
WITH (
	OIDS=FALSE
);

CREATE TABLE file_key_test.encryption_key (
	encryption_key_id int8 NOT NULL,
	alias varchar(128) NOT NULL,
	encryption_key text NOT NULL
) ;


CREATE SEQUENCE dev_ega_file.download_log_new_download_log_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1;

CREATE SEQUENCE dev_ega_file.event_event_id_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9223372036854775807
START 1;

CREATE TABLE dev_ega_file.file_index_file (
	file_id varchar(128) NULL,
	index_file_id varchar(128) NULL
)
WITH (
	OIDS=FALSE
);

CREATE TABLE dev_ega_file.file_dataset (
	dataset_id varchar(128) NULL,
	file_id varchar(128) NULL
)
WITH (
	OIDS=FALSE
);
CREATE UNIQUE INDEX dataset_id_idx ON dev_ega_file.file_dataset (dataset_id, file_id);
CREATE INDEX file_id_idx ON dev_ega_file.file_dataset (file_id);

CREATE TABLE dev_ega_file.file (
	file_id  varchar(128) NULL,
	file_name varchar(256) NULL,
        file_path varchar (256) NULL,
        display_file_name varchar (128) NULL,
	file_size int8 NULL,
        checksum varchar(128) NULL,
        checksum_type varchar(12) NULL,
        unencrypted_checksum varchar(128) NULL,
        unencrypted_checksum_type varchar(12) NULL,
	file_status varchar(13) NULL,
        created_by varchar(25) NULL,
        last_updated_by varchar(25) NULL,
        header text NULL,
        created timestamp NOT NULL DEFAULT now(),
        last_updated timestamp NOT NULL DEFAULT now()
)
WITH (
	OIDS=FALSE
);

CREATE TABLE dev_ega_file.event (
	event_id int8 NOT NULL DEFAULT nextval('dev_ega_file.event_event_id_seq'::regclass),
	client_ip varchar(45) NOT NULL,
	event varchar(256) NOT NULL,
	event_type varchar(256) NOT NULL,
	email varchar(256) NOT NULL,
	created timestamp NOT NULL DEFAULT now(),
	CONSTRAINT event_pkey PRIMARY KEY (event_id)
)
WITH (
	OIDS=FALSE
);

CREATE TABLE dev_ega_file.download_log (
	download_log_id int8 NOT NULL DEFAULT nextval('dev_ega_file.download_log_new_download_log_id_seq'::regclass),
	client_ip varchar(45) NOT NULL,
	api varchar(45) NOT NULL,
	email varchar(256) NOT NULL,
	file_id varchar(15) NOT NULL,
	download_speed float8 NOT NULL DEFAULT '-1'::integer,
	download_status varchar(256) NOT NULL DEFAULT 'success'::character varying,
	encryption_type varchar(256) NOT NULL,
	start_coordinate int8 NOT NULL DEFAULT 0,
	end_coordinate int8 NOT NULL DEFAULT 0,
	bytes int8 NOT NULL DEFAULT 0,
	created timestamp NOT NULL DEFAULT now(),
        token_source varchar(255) NOT NULL
)
WITH (
	OIDS=FALSE
);

INSERT INTO file_key_test.key_format_cv VALUES('plain', true);
INSERT INTO file_key_test.key_format_cv VALUES('aes128', true);
INSERT INTO file_key_test.key_format_cv VALUES('aes256', true);

INSERT INTO dev_ega_file.file_key VALUES('EGAF00000000014', 1, 'plain');

INSERT INTO dev_ega_file.file VALUES('EGAF00000000014', 's3://elixir-excelerate/SRR1515811.cram.cip', 's3://elixir-excelerate/SRR1515811.cram.cip' , 'SRR1515811Displayname.cram.cip', 3722995313, '497beea5df3909705dfaed5901306c1d', 'MD5','497beea5df3909705dfaed5901306c1d', 'plain',  'available', '16/08/2018', '16/08/2018', 'header');

INSERT INTO dev_ega_file.file_dataset values('EGAD00010000919', 'EGAF00000000014');

INSERT INTO dev_ega_file.file_index_file values('EGAF00000000014', 'EGAI00000000001');

INSERT INTO file_key_test.encryption_key VALUES(1, 'alias', 'encryption_key');
