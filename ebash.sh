#!/bin/bash
set -ue
set -o pipefail

REMOTE_IP=${1:-}
VERBOSE=${VERBOSE:-}
SSH_KEY=${SSH_KEY:-}

if [ -n "${VERBOSE}" ] ; then
    set -x
fi

# Logging stuff.
# shellcheck disable=SC1117,SC2145
e_error(){ echo -e " \033[1;31m✖\033[0m  $@"; }
# shellcheck disable=SC1117,SC2145
e_arrow(){ echo -e " \033[1;34m➜\033[0m  $@"; }

_ssh(){
    local ssh_args=''
    if [ -n "${SSH_KEY}" ] ; then
        ssh_args="-i ${SSH_KEY}"
    fi
    ssh $(eval echo "${ssh_args}") "${REMOTE_IP}" "$@"
}
precheck(){
  if [ -z "${REMOTE_IP}" ] ; then
      e_error "REMOTE_IP should be passed as positional argument"
      exit 1
  fi
}

install_dependencies(){
    e_arrow "Updating packages meta..."
    _ssh sudo apt update
    e_arrow "Installing ruby..."
    _ssh sudo apt install -fy ruby
    e_arrow "Installing tmuxinator"
    _ssh sudo gem install tmuxinator
}

configure_bashrc(){
    e_arrow "Add some magic to user .bashrc..."
    _ssh 'echo "export EDITOR=vim" >> $HOME/.bashrc'
}

setup_tmux(){
    e_arrow "Add config template for tmux..."
    CONF_TEMPLATE="name: k8s
root: ~/
pre_window: export KUBECONFIG=/root/.kube/config
windows:
  - bash:
      layout: (4a85,177x46,0,0[177x23,0,0{88x23,0,0,1,88x23,89,0,7},177x22,0,24,6)
      panes:
        - kubectl get openstackdeployments -n openstack osh-dev -o yaml > osh-dev.yaml && vim osh-dev.yaml
        -
        -
  - barbican:
      panes:
        - kubectl logs -f deployment/barbican-api -n openstack
  - cinder:
      panes:
        - kubectl logs -f deployment/cinder-api -n openstack
  - designate:
      layout: main-horizontal
      panes:
        - kubectl logs -f deployment/designate-api -n openstack
        - kubectl logs -f deployment/powerdns -n openstack
  - glance:
      panes:
        - kubectl logs -f deployment/glance-api -n openstack
  - heat:
      panes:
        - kubectl logs -f deployment/heat-api -n openstack
  - keystone:
      panes:
        - kubectl logs -f deployment/keystone-api -n openstack
  - neutron:
      panes:
        - kubectl logs -f deployment/neutron-server -n openstack
  - nova:
      panes:
        - kubectl logs -f deployment/nova-api -n openstack
  - octavia:
      panes:
        - kubectl logs -f deployment/octavia-api -n openstack
"
    _ssh 'mkdir -p $HOME/.config/tmuxinator'
    echo "${CONF_TEMPLATE}" | _ssh 'cat > ~/.config/tmuxinator/k8s.yaml'
}

start_tmux(){
    e_arrow "Starting remote tmux session..."
    _ssh 'sudo tmuxinator start k8s &'
}

precheck
install_dependencies
configure_bashrc
setup_tmux
start_tmux
