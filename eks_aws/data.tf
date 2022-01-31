data "template_file" "userdata" {
    count = var.create_with_autoscaling == true ? 1 : 0
    template = file("${path.module}/templates/userdata.sh.tpl")

    vars = {
        cluster_name = aws_eks_cluster.cluster.id
        endpoint = aws_eks_cluster.cluster.endpoint
        cluster_auth_base64 = aws_eks_cluster.cluster.certificate_authority[0].data
    }
}