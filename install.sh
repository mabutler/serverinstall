#!/bin/sh
pacman -S --needed --noconfirm $(cat package.list)
