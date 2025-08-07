# gocat

A simple Go program that adds beautiful rainbow colors to your terminal output by reading from stdin and colorizing each character with smooth RGB transitions.

## Description

**gocat** is a command-line utility that takes input from stdin and outputs each character with gradually changing colors, creating a rainbow effect in your terminal. The program uses ANSI escape codes to apply 24-bit RGB colors, with each character getting a unique color based on a sine wave calculation.

The program is designed to be used as a filter in Unix pipelines, similar to how you would use `cat` but with colorful output.

## Features

- **Rainbow text output** with smooth color transitions
- Works with any text input through stdin
- Uses 24-bit RGB colors for terminals that support them
- Lightweight and fast
- Compatible with Unix pipelines

## Installation

```bash
chmod +x install.sh
./install.sh
```



**Note:** Your terminal must support ANSI colors and 24-bit RGB for the best experience. Most modern terminals support this feature.

## Requirements

- Terminal with ANSI color support
- 24-bit RGB color support for full rainbow effect

## How it Works

The program uses mathematical sine functions to generate smooth color transitions:
- Each character gets a unique RGB value based on its position
- Colors cycle through the spectrum using phase-shifted sine waves
- ANSI escape sequences apply the colors to terminal output