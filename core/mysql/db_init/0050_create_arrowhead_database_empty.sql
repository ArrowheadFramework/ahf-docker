CREATE DATABASE  IF NOT EXISTS `arrowhead`
  /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `arrowhead`;

/*!40101 SET NAMES utf8 */;

--
-- Table structure for table `arrowhead_cloud`
--

DROP TABLE IF EXISTS `arrowhead_cloud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arrowhead_cloud` (
  `id` int(11) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `authentication_info` varchar(255) DEFAULT NULL,
  `cloud_name` varchar(255) DEFAULT NULL,
  `gatekeeper_service_uri` varchar(255) DEFAULT NULL,
  `operator` varchar(255) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`operator`,`cloud_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `arrowhead_service`
--

DROP TABLE IF EXISTS `arrowhead_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arrowhead_service` (
  `id` int(11) NOT NULL,
  `service_definition` varchar(255) DEFAULT NULL,
  `service_group` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`service_group`,`service_definition`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `arrowhead_service_interface_list`
--

DROP TABLE IF EXISTS `arrowhead_service_interface_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arrowhead_service_interface_list` (
  `arrowhead_service_id` int(11) NOT NULL,
  `interfaces` varchar(255) DEFAULT NULL,
  KEY (`arrowhead_service_id`),
  CONSTRAINT FOREIGN KEY (`arrowhead_service_id`) REFERENCES `arrowhead_service` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `arrowhead_service_metadata_map`
--

DROP TABLE IF EXISTS `arrowhead_service_metadata_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arrowhead_service_metadata_map` (
  `service_id` int(11) NOT NULL,
  `metadata_value` varchar(255) DEFAULT NULL,
  `metadata_key` varchar(255) NOT NULL,
  PRIMARY KEY (`service_id`,`metadata_key`),
  CONSTRAINT FOREIGN KEY (`service_id`) REFERENCES `arrowhead_service` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `arrowhead_system`
--

DROP TABLE IF EXISTS `arrowhead_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arrowhead_system` (
  `id` int(11) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `authentication_info` longtext,
  `port` int(11) DEFAULT NULL,
  `system_group` varchar(255) DEFAULT NULL,
  `system_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`system_group`,`system_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_system`
--

DROP TABLE IF EXISTS `core_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `core_system` (
  `id` int(11) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `authentication_info` varchar(255) DEFAULT NULL,
  `is_secure` bit(1) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `service_uri` varchar(255) DEFAULT NULL,
  `system_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`system_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hibernate_sequence`
--

DROP TABLE IF EXISTS `hibernate_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hibernate_sequence` (
  `next_val` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `hibernate_sequence` WRITE;
/*!40000 ALTER TABLE `hibernate_sequence` DISABLE KEYS */;
INSERT INTO `hibernate_sequence` VALUES (1),(1),(1),(1),(1),(1),(1),(1);
/*!40000 ALTER TABLE `hibernate_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inter_cloud_authorization`
--

DROP TABLE IF EXISTS `inter_cloud_authorization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inter_cloud_authorization` (
  `id` int(11) NOT NULL,
  `consumer_cloud_id` int(11) DEFAULT NULL,
  `arrowhead_service_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`consumer_cloud_id`,`arrowhead_service_id`),
  KEY (`arrowhead_service_id`),
  CONSTRAINT FOREIGN KEY (`arrowhead_service_id`) REFERENCES `arrowhead_service` (`id`),
  CONSTRAINT FOREIGN KEY (`consumer_cloud_id`) REFERENCES `arrowhead_cloud` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `intra_cloud_authorization`
--

DROP TABLE IF EXISTS `intra_cloud_authorization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intra_cloud_authorization` (
  `id` int(11) NOT NULL,
  `consumer_system_id` int(11) DEFAULT NULL,
  `provider_system_id` int(11) DEFAULT NULL,
  `arrowhead_service_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`consumer_system_id`,`provider_system_id`,`arrowhead_service_id`),
  KEY (`provider_system_id`),
  KEY (`arrowhead_service_id`),
  CONSTRAINT FOREIGN KEY (`arrowhead_service_id`) REFERENCES `arrowhead_service` (`id`),
  CONSTRAINT FOREIGN KEY (`consumer_system_id`) REFERENCES `arrowhead_system` (`id`),
  CONSTRAINT FOREIGN KEY (`provider_system_id`) REFERENCES `arrowhead_system` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `neighbor_cloud`
--

DROP TABLE IF EXISTS `neighbor_cloud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `neighbor_cloud` (
  `cloud_id` int(11) NOT NULL,
  PRIMARY KEY (`cloud_id`),
  CONSTRAINT FOREIGN KEY (`cloud_id`) REFERENCES `arrowhead_cloud` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orchestration_store`
--

DROP TABLE IF EXISTS `orchestration_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orchestration_store` (
  `id` int(11) NOT NULL,
  `instruction` varchar(255) DEFAULT NULL,
  `is_default` bit(1) DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `service_uri` varchar(255) DEFAULT NULL,
  `consumer_system_id` int(11) DEFAULT NULL,
  `provider_cloud_id` int(11) DEFAULT NULL,
  `provider_system_id` int(11) DEFAULT NULL,
  `arrowhead_service_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`arrowhead_service_id`,`consumer_system_id`,`priority`,`is_default`),
  KEY (`consumer_system_id`),
  KEY (`provider_cloud_id`),
  KEY (`provider_system_id`),
  CONSTRAINT FOREIGN KEY (`provider_system_id`) REFERENCES `arrowhead_system` (`id`),
  CONSTRAINT FOREIGN KEY (`provider_cloud_id`) REFERENCES `arrowhead_cloud` (`id`),
  CONSTRAINT FOREIGN KEY (`consumer_system_id`) REFERENCES `arrowhead_system` (`id`),
  CONSTRAINT FOREIGN KEY (`arrowhead_service_id`) REFERENCES `arrowhead_service` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orchestration_store_attributes`
--

DROP TABLE IF EXISTS `orchestration_store_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orchestration_store_attributes` (
  `store_entry_id` int(11) NOT NULL,
  `attribute_value` varchar(255) DEFAULT NULL,
  `attribute_key` varchar(255) NOT NULL,
  PRIMARY KEY (`store_entry_id`,`attribute_key`),
  CONSTRAINT FOREIGN KEY (`store_entry_id`) REFERENCES `orchestration_store` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `own_cloud`
--

DROP TABLE IF EXISTS `own_cloud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `own_cloud` (
  `cloud_id` int(11) NOT NULL,
  PRIMARY KEY (`cloud_id`),
  CONSTRAINT FOREIGN KEY (`cloud_id`) REFERENCES `arrowhead_cloud` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_registry`
--

DROP TABLE IF EXISTS `service_registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_registry` (
  `id` int(11) NOT NULL,
  `service_uri` varchar(255) DEFAULT NULL,
  `arrowhead_service_id` int(11) DEFAULT NULL,
  `provider_system_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`arrowhead_service_id`,`provider_system_id`),
  KEY (`provider_system_id`),
  CONSTRAINT FOREIGN KEY (`provider_system_id`) REFERENCES `arrowhead_system` (`id`),
  CONSTRAINT FOREIGN KEY (`arrowhead_service_id`) REFERENCES `arrowhead_service` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
