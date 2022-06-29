setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "has_shebang() - #!/bin/sh" {
  source "$PROJECT_ROOT/src/functions.sh"

  echo -e "#!/bin/sh\n\nshell" > shell.sh
  echo -e "shell" > file.txt
  touch empty.txt

  run has_shebang "shell.sh"
  assert_success

  run has_shebang
  assert_failure 1

  run has_shebang "file.txt"
  assert_failure 2

  run has_shebang "empty.txt"
  assert_failure 3
}

@test "has_shebang() - #!/bin/bash" {
  source "$PROJECT_ROOT/src/functions.sh"

  echo -e "#!/bin/bash\n\nbash" > shell.sh
  echo -e "bash" > file.txt
  touch empty.txt

  run has_shebang "shell.sh"
  assert_success

  run has_shebang
  assert_failure 1

  run has_shebang "file.txt"
  assert_failure 2

  run has_shebang "empty.txt"
  assert_failure 3
}

@test "has_shebang() - TYPO" {
  source "$PROJECT_ROOT/src/functions.sh"

  echo -e "#!/bin/bashees" > shell.sh

  run has_shebang "shell.sh"
  assert_failure 2

  echo -e "#!/bin/s" > shell.sh

  run has_shebang "shell.sh"
  assert_failure 2
}

teardown () {
  rm -f shell.sh file.txt empty.txt
}
