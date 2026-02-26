---
slug: "python-project-setup"
title: "Setting Up a Python Project with venv and pyproject.toml"
description: "A quick guide on how to initialize a Python project using virtual environments, the src-layout, and pyproject.toml."
tags: ["python", "utils"]
date: 2026-02-25
---

## Setting Up the Project Directory

We start by creating the directory where the project will live:

```bash
mkdir python-project
cd python-project

```

From here, this will be our `root` where the entire project will live and where we will be using a virtual environment with `venv`.

Check which version of Python we have:

```bash
python --version

```

## Initializing the Virtual Environment

After we make sure that we have all what we need, now we will be initializing the virtual environment:

```bash
python -m venv .venv

```

We tell Python to create it using the `venv` module and use the `.venv` folder to fill it with its files.

## Activating the Virtual Environment

From now on, whenever we want to activate the virtual environment we will be using:

```bash
source .venv/bin/activate

```

To know if it started correctly, a `(.venv)` should appear in your terminal:

```text
(.venv) user@host:~/python-project $

```

## Creating the pyproject.toml File

Now we can start creating the `pyproject.toml` file:

```bash
touch pyproject.toml

```

This file is the source of truth that pip will look at to know how your package will work. Here are three important things you need to add to start the project:

- `[build-system]`: This will indicate what your project will need (`requires`) and how it should be treated (`build-backend`).
- `[project]`: Here is for two important things, the metadata (`author`, `name`, `description`, etc.) and establishing versioning (`dependencies`, `requires-python`, `version`).

We start with that in our file:

```toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "cool-pyscript"
version = "0.1.0"
requires-python = ">=3.11"

```

## Structuring the Project (src-layout)

Making the directory structure, we will be using the most recent standard, the **src-layout**.

This structure is composed of two main files:

```text
python-project
└── src
    └── cool_pyscript
        ├── __init__.py
        └── main.py

```

- `main.py` is what will initialize the entire script. Normally, it is an orchestrator that imports the main files that run the entire project.
- `__init__.py` tells Python "hey, this directory is a package, so treat it as one", which later makes it available for you to use the directory to import other files like `import cool_pyscript.cool_file`.
- `src/` is the folder that contains all the source code. The name is not strictly necessary since we later can tell `pyproject.toml` where the source directory is, but it is highly recommended since it is the standard to call it this way.
- `cool_pyscript` this is likely the real "project" where we will be coding. The name is irrelevant and could be any, but it is also a good practice to call it with a similar name as the project name in the `pyproject.toml`.

> [!IMPORTANT]
> The naming on the files matters!
> Notice how I use "cool-pyscript" as the name in `pyproject.toml`, but name the actual folder as "cool\*pyscript". This is because Python considers `-` a special character (a dash means a subtraction operation in Python), so I change it to `_` which acts like an actual alphabet character for Python module names.

## Coding the Main Script

Now we can start coding.

From here we can start making our stuff, like adding a light database if needed, adding more dependencies if needed, making classes, etc.
What we must ensure in this part, is to have a clean start in `main.py`, with a main function that initializes the entire app and a **name-main idiom** to debug if needed.

```python
def main():
  print("Hello World!")

if __name__ == "__main__":
  main()

```

- `main()`: This is the function that will initialize the entire script and orchestrate other packages. The name is not strictly relevant and can be named as you want.
- **`if __name__ == "__main__"` idiom** or **name-main idiom**: This is a useful way to debug and test the current development without installing the entire script. This allows us to simply execute it with:

```bash
python src/cool_pyscript/main.py

```

## Adding a Custom Terminal Command

Make a custom command to use in the terminal.

For this we must add some new options in the `pyproject.toml`:

```toml
#... Same config as above
[project.scripts]
cool-script-name = "cool_pyscript.main:main"

[tool.setuptools.packages.find]
where = ["src"]

```

- `[tool.setuptools.packages.find]`: On this block, we tell Python where the source code is living. As I said earlier, the `src/` folder name is not forced to be used and can be configured here if another name was used.
- `[project.scripts]`: Here we declare to Python how to name our custom command and what it will trigger. In the example above we tell it "hey, call my command `cool-script-name`, and this command will call `main()` from `cool_pyscript.main` (`src/cool_pyscript/main.py`)".

With that covered, now we only need to install the project to make use of the command:

```bash
pip install -e .

```

This will install the Python package and make the command "editable". This means you can still use the terminal command even if you change the source code later (adding features, refactoring) without having to reinstall it every time you modify the files.

Now we can use the command as:

```text
$ cool-script-name

```

## Summary

- `pyproject.toml`: Instructions for pip about how to manage our script.

```toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "cool-pyscript"
version = "0.1.0"
requires-python = ">=3.11"

[project.scripts]
cool-script-name = "cool_pyscript.main:main"

[tool.setuptools.packages.find]
where = ["src"]

```

- Directory structure:

```text
python-project
├── .venv/
├── pyproject.toml
└── src
    └── cool_pyscript
        ├── __init__.py
        └── main.py

```

- `main.py`: Orchestrator that initializes the entire script/project.

```python
def main():
  print("Hello World!")

if __name__ == "__main__":
  main()

```

Done!
