#!/bin/bash
ssh miraikan@10.0.0.254 'bash -c "/opt/vyatta/bin/vyatta-op-cmd-wrapper shutdown at 00"'
read -rsp $'Press any key to continue...\n' -n1 key
