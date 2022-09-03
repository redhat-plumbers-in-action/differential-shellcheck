setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "has_shebang() - #!/bin/{,a,ba,da,k}sh & #!/bin/bats" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/bin/'{,a,ba,da,k}sh
    '#!/bin/bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - #!/usr/bin/{,a,ba,da,k}sh & #!/usr/bin/bats" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/usr/bin/'{,a,ba,da,k}sh
    '#!/usr/bin/bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - #!/usr/local/bin/{,a,ba,da,k}sh & #!/usr/local/bin/bats" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/usr/local/bin/'{,a,ba,da,k}sh
    '#!/usr/local/bin/bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - #!/bin/env {,a,ba,da,k}sh & #!/bin/env bats" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/bin/env '{,a,ba,da,k}sh
    '#!/bin/env bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - #!/usr/bin/env {,a,ba,da,k}sh & #!/usr/bin/env bats" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/usr/bin/env '{,a,ba,da,k}sh
    '#!/usr/bin/env bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - #!/usr/local/bin/env {,a,ba,da,k}sh & #!/usr/local/bin/env bats" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/usr/local/bin/env '{,a,ba,da,k}sh
    '#!/usr/local/bin/env bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

# Source: https://stackoverflow.com/a/17409966
@test "has_shebang() - SPACES" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local space_bin=(
    ' # ! /bin/'{,a,ba,da,k}sh' '
    ' # ! /bin/bats '
  )
  local space_usr_bin=(
    ' # ! /usr/bin/'{,a,ba,da,k}sh' '
    ' # ! /usr/bin/bats '
  )
  local space_usr_local_bin=(
    ' # ! /usr/local/bin/'{,a,ba,da,k}sh' '
    ' # ! /usr/local/bin/bats '
  )
  local space_bin_env=(
    ' # ! /bin/env '{,a,ba,da,k}sh' '
    ' # ! /bin/env bats '
  )
  local space_usr_bin_env=(
    ' # ! /usr/bin/env '{,a,ba,da,k}sh' '
    ' # ! /usr/bin/env bats '
  )
  local space_usr_local_bin_env=(
    ' # ! /usr/local/bin/env '{,a,ba,da,k}sh' '
    ' # ! /usr/local/bin/env bats '
  )

  for i in "${!space_bin[@]}"; do
    echo -e "${space_bin[i]}\n\nshell" > script
    
    run has_shebang "script"
    assert_success

    echo -e "${space_usr_bin[i]}\n\nshell" > script
    
    run has_shebang "script"
    assert_success

    echo -e "${space_usr_local_bin[i]}\n\nshell" > script
    
    run has_shebang "script"
    assert_success

    echo -e "${space_bin_env[i]}\n\nshell" > script
    
    run has_shebang "script"
    assert_success

    echo -e "${space_usr_bin_env[i]}\n\nshell" > script
    
    run has_shebang "script"
    assert_success

    echo -e "${space_usr_local_bin_env[i]}\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - PARAMETERS" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    '#!/bin/'{,a,ba,da,k}sh'  --something-something  -s something'
    '#!/bin/bats  --something-something  -s something'
  )

  for i in "${interpreters[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - FORGOTTEN OR SWITCHED" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local templates=( {'!','#','#!','# !','!#','! #'}'/bin/sh' )

  for i in "${templates[@]}"; do
    echo -e "$i\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - SHELL DIRECTIVE" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local interpreters=(
    {,a,ba,da,k}sh
    'bats'
  )

  for i in "${interpreters[@]}"; do
    echo -e "#!/bin/mywrapper\n# shellcheck shell=${i}\n\nshell" > script
    
    run has_shebang "script"
    assert_success
  done
}

@test "has_shebang() - TYPO" {
  source "${PROJECT_ROOT}/src/functions.sh"

  echo -e '#!/bin/bashees\n\nshell' > script

  run has_shebang "script"
  assert_failure 2

  echo -e '#!/bin/s\n\nshell' > script

  run has_shebang "script"
  assert_failure 2
}

@test "has_shebang() - INPUTS" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run has_shebang
  assert_failure 1

  echo -e "shell" > file.txt
  run has_shebang "file.txt"
  assert_failure 2

  touch empty.txt
  run has_shebang "empty.txt"
  assert_failure 2
}

teardown () {
  rm -f script file.txt empty.txt
}
