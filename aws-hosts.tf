resource "aws_instance" "boundary_public_target" {
  ami               = "ami-04075458d3b9f6a5b"
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  user_data_base64  = data.cloudinit_config.ssh_trusted_ca.rendered

  network_interface {
    network_interface_id = aws_network_interface.boundary_public_target_ni.id
    device_index         = 0
  }

  tags = {
    Name         = "boundary-1-dev"
    service-type = "database"
    application  = "dev"
  }
}

resource "aws_network_interface" "boundary_public_target_ni" {
  subnet_id               = aws_subnet.boundary_ingress_worker_subnet.id
  security_groups         = [aws_security_group.static_target_sg.id]
  private_ip_list_enabled = false
}

data "cloudinit_config" "ssh_trusted_ca" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    sudo curl -o /etc/ssh/trusted-user-ca-keys.pem \
    --header "X-Vault-Namespace: admin" \
    -X GET \
    ${var.vault_addr}/v1/ssh-client-signer/public_key
    sudo echo TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem >> /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
    EOF
  }

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
    users:
      - default
      - name: amar
        expiredate: '2032-09-01'
        lock_passwd: false
        passwd: $6$rounds=4096$.xsfhXTRCTS.wJN4$rTMuuez0oLothz5XzZ/fc6uikSbaIUvShrtLI1e/.plDal6GidQuSt7n10TMLHUkBdIPwuUXaOnLhLFxdtXhM0
      - name: admin
        expiredate: '2032-09-01'
        lock_passwd: false
        passwd: $6$rounds=4096$.xsfhXTRCTS.wJN4$rTMuuez0oLothz5XzZ/fc6uikSbaIUvShrtLI1e/.plDal6GidQuSt7n10TMLHUkBdIPwuUXaOnLhLFxdtXhM0
        groups: wheel
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    sudo echo "%wheel ALL=(ALL) NOPASSWD: /bin/su" > /etc/sudoers.d/wheel-nopasswd
    sudo echo "%wheel ALL=(ALL) NOPASSWD: /bin/sudo" >> /etc/sudoers.d/wheel-nopasswd
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    sudo mkdir /etc/demodir
    echo "This is a test file. You are allowed to read this" | sudo tee /etc/demodir/testfile.txt
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    sudo visudo -f /etc/sudoers.d/readonly_services
    ## Restricting amar to read-only access to /etc/demodir directory
    Cmnd_Alias READ_ONLY_DEMODIR = /bin/cat /etc/demodir/*
    amar ALL=(ALL) READ_ONLY_DEMODIR
    EOF
  }
}
