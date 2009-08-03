CREATE TABLE `album_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `albums` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `artist_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `year` int(11) DEFAULT NULL,
  `original_year` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `albumart_id` int(11) DEFAULT NULL,
  `discs_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_albums_on_albumart_id` (`albumart_id`),
  KEY `index_albums_on_artist_id` (`artist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `artists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audio_content` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `size` int(11) NOT NULL,
  `md5` tinyblob NOT NULL,
  `sha2` tinyblob NOT NULL,
  `format` varchar(255) NOT NULL,
  `bitrate` int(11) DEFAULT NULL,
  `length` float DEFAULT NULL,
  `samplerate` int(11) DEFAULT NULL,
  `vbr` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_audio_content_on_size` (`size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audio_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `audio_content_id` int(11) NOT NULL,
  `dirname` text NOT NULL,
  `basename` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `location_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_audio_files_on_location_id` (`location_id`),
  KEY `index_audio_files_on_audio_content_id` (`audio_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audio_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `audio_file_id` int(11) NOT NULL,
  `format` varchar(8) NOT NULL,
  `version` varchar(10) DEFAULT NULL,
  `offset` int(11) NOT NULL,
  `data` mediumblob NOT NULL,
  `albumart_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_audio_tags_on_albumart_id` (`albumart_id`),
  KEY `index_audio_tags_on_audio_file_id` (`audio_file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audio_tags_tracks` (
  `audio_tag_id` int(11) NOT NULL,
  `track_id` int(11) NOT NULL,
  UNIQUE KEY `index_audio_tags_tracks_on_audio_tag_id_and_track_id` (`audio_tag_id`,`track_id`),
  KEY `index_audio_tags_tracks_on_track_id` (`track_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bdrb_job_queues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `args` text,
  `worker_name` varchar(255) DEFAULT NULL,
  `worker_method` varchar(255) DEFAULT NULL,
  `job_key` varchar(255) DEFAULT NULL,
  `taken` int(11) DEFAULT NULL,
  `finished` int(11) DEFAULT NULL,
  `timeout` int(11) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `archived_at` datetime DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  `submitter_info` varchar(255) DEFAULT NULL,
  `runner_info` varchar(255) DEFAULT NULL,
  `worker_key` varchar(255) DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `discs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) NOT NULL,
  `album_type_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `order_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_discs_on_album_id_and_order_id` (`album_id`,`order_id`),
  KEY `index_discs_on_album_type_id` (`album_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `size` int(11) NOT NULL,
  `data` mediumblob NOT NULL,
  `mimetype` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_on_size` (`size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dir` text NOT NULL,
  `label` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `scanner_errors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) NOT NULL,
  `file` text NOT NULL,
  `err_msg` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_scanner_errors_on_location_id` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `scanner_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) NOT NULL,
  `started` datetime NOT NULL,
  `ended` datetime DEFAULT NULL,
  `files_scanned` int(11) DEFAULT NULL,
  `file_count` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL,
  `aborted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_scanner_logs_on_location_id_and_active` (`location_id`,`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `search_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `params` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_search_queries_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `disc_id` int(11) NOT NULL,
  `tn` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `audio_file_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tracks_on_audio_file_id` (`audio_file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090608100525');

INSERT INTO schema_migrations (version) VALUES ('20090618104349');

INSERT INTO schema_migrations (version) VALUES ('20090625104203');

INSERT INTO schema_migrations (version) VALUES ('20090706042153');

INSERT INTO schema_migrations (version) VALUES ('20090707024941');

INSERT INTO schema_migrations (version) VALUES ('20090709152523');

INSERT INTO schema_migrations (version) VALUES ('20090711233751');

INSERT INTO schema_migrations (version) VALUES ('20090713071138');

INSERT INTO schema_migrations (version) VALUES ('20090714151131');

INSERT INTO schema_migrations (version) VALUES ('20090714153203');

INSERT INTO schema_migrations (version) VALUES ('20090715194431');

INSERT INTO schema_migrations (version) VALUES ('20090718221624');

INSERT INTO schema_migrations (version) VALUES ('20090719161948');

INSERT INTO schema_migrations (version) VALUES ('20090722095012');

INSERT INTO schema_migrations (version) VALUES ('20090724093539');

INSERT INTO schema_migrations (version) VALUES ('20090724221744');

INSERT INTO schema_migrations (version) VALUES ('20090802102256');

INSERT INTO schema_migrations (version) VALUES ('20090802153304');

INSERT INTO schema_migrations (version) VALUES ('20090803084224');