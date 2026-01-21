target "app-vpn" {
  tags = ["local-image:vpn"]
  dockerfile = "Dockerfile.vpn"
  contexts = {
    // Credits: Philip Couling
    // https://stackoverflow.com/questions/36362233/can-a-dockerfile-extend-another-one
    //
    // Target `app` will be automatically parsed from docker-compose.yml
    main-dockerfile = "target:app"
  }
}
