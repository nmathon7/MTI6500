#!/bin/bash

pdsh -w 10.10.28.13[0-6] sudo -u USERNAME $OBH/bin/ozone --daemon stop datanode
