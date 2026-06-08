let
  host_aconcagua_TPM = "age1tag1qf9r32c8ev6r8c36sl7r627xrs9wtlqvcw2szc4uz20sfm3xzw3gujw9ysm";
  host_amaru = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd10I5SWSx0CeG3E/C0n/lw5FWbTS39raZJjwNMl9iB root@amaru";
in
{
  "security/secrets/kanidm_admin_password.age".publicKeys = [
    host_aconcagua_TPM
    host_amaru
  ];
  "security/secrets/kanidm_idm_admin_password.age".publicKeys = [
    host_aconcagua_TPM
    host_amaru
  ];
}
