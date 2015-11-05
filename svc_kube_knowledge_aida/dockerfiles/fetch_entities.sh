#!/bin/bash

cd /var/lib/docker
mkdir -p kube-aida/datasets
cd kube-aida/datasets

echo "Fetch AIDA Knowledge Base from a recent Wikipedia dump: 32Gb"
wget -nc http://resources.mpi-inf.mpg.de/yago-naga/aida/download/entity-repository/AIDA_entity_repository_2014-01-02v10.sql.bz2

echo "Fetch AIDA Knowledge Base in-memory dmap: 13Gb"
wget -nc http://resources.mpi-inf.mpg.de/yago-naga/aida/download/entity-repository/AIDA_entity_repository_2014-01-02v10_dmap.tar.bz2

echo "Fetch EDRAK: Entity-Centric Data Resource for Arabic Knowledge: 22Gb"
wget -nc http://resources.mpi-inf.mpg.de/yago-naga/aida/download/entity-repository/edrak_en20150112_ar20141218.sql.bz2

echo "Fetch AIDA-EE Dataset: 119Kb"
wget -nc http://resources.mpi-inf.mpg.de/yago-naga/aida/download/AIDA-EE.tar.gz

echo "Fetch KORE Datasets, 20 seed entities from 4 domains (IT companies, Hollywood celebrities, video games, television series): 5Kb"
wget -nc http://resources.mpi-inf.mpg.de/yago-naga/aida/download/KORE_entity_relatedness.tar.gz
