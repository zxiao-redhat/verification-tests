Feature: Descheduler major upgrade should work fine

  # @author knarra@redhat.com
  @admin
  @upgrade-prepare
  @users=upuser1,upuser2
  @destructive
  @4.13 @4.12 @4.11 @4.10 @4.9 @4.8 @4.7
  @vsphere-ipi @openstack-ipi @nutanix-ipi @ibmcloud-ipi @gcp-ipi @baremetal-ipi @azure-ipi @aws-ipi @alicloud-ipi
  @vsphere-upi @openstack-upi @nutanix-upi @ibmcloud-upi @gcp-upi @baremetal-upi @azure-upi @aws-upi @alicloud-upi
  @upgrade
  @network-ovnkubernetes @network-openshiftsdn
  @proxy @noproxy @disconnected @connected
  @heterogeneous @arm64 @amd64
  @hypershift-hosted
  Scenario: upgrade - upgrade descheduler from 4.x to 4.y - prepare
    Given I switch to cluster admin pseudo user
    Given I store master major version in the clipboard
    Given kubedescheduler operator has been installed successfully
    Given I use the "openshift-kube-descheduler-operator" project
    Given I obtain test data file "descheduler/kubedescheduler-<%= cb.master_version %>.yaml"
    When I run the :create admin command with:
      | f | kubedescheduler-<%= cb.master_version %>.yaml |
    Then the step should succeed
    Given 60 seconds have passed
    And status becomes :running of exactly 1 pods labeled:
      | app=descheduler |
    Given evaluation of `pod.name` is stored in the :pod_name clipboard
    Given I wait up to 180 seconds for the steps to pass:
    """
    When I run the :logs client command with:
      | resource_name | pod/<%= cb.pod_name %> |
    And the output should contain:
      | duplicates.go               |
      | lownodeutilization.go       |
      | pod_antiaffinity.go         |
      | node_affinity.go            |
      | node_taint.go               |
      | toomanyrestarts.go          |
      | pod_lifetime.go             |
      | topologyspreadconstraint.go |
    """

  # @author knarra@redhat.com
  # @case_id OCP-40536
  @admin
  @upgrade-check
  @users=upuser1,upuser2
  @destructive
  @4.13 @4.12 @4.11 @4.10 @4.9 @4.8 @4.7
  @vsphere-ipi @openstack-ipi @nutanix-ipi @ibmcloud-ipi @gcp-ipi @baremetal-ipi @azure-ipi @aws-ipi @alicloud-ipi
  @vsphere-upi @openstack-upi @nutanix-upi @ibmcloud-upi @gcp-upi @baremetal-upi @azure-upi @aws-upi @alicloud-upi
  @upgrade
  @network-ovnkubernetes @network-openshiftsdn
  @proxy @noproxy @disconnected @connected
  @heterogeneous @arm64 @amd64
  @hypershift-hosted
  Scenario: upgrade - upgrade descheduler from 4.x to 4.y
    Given I switch to cluster admin pseudo user
    And I use the "openshift-kube-descheduler-operator" project
    Given I store master major version in the clipboard
    Given a pod becomes ready with labels:
      | app=descheduler |
    Given I make sure the descheduler operator gets updated successfully if needed
    And I use the "openshift-kube-descheduler-operator" project
    And status becomes :running of exactly 1 pods labeled:
      | name=descheduler-operator |
    Given I wait up to 180 seconds for the steps to pass:
    """
    And status becomes :running of exactly 1 pods labeled:
      | app=descheduler |
    """
    When I run the :get client command with:
      | resource     | csv                                 |
      | n            | openshift-kube-descheduler-operator |
    Then the step should succeed
    And the output should match "clusterkubedescheduleroperator.*<%= cb.master_version %>.*Succeeded"
