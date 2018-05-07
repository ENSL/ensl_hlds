#!/bin/bash

sudo taskset -a -p -c 1 `pgrep hlds_linux`
sudo renice -20 `pgrep hlds_linux`
