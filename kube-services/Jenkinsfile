node('master') {
  sh "echo 'Starting kraken services build ${currentBuild.displayName}' | hipchat_room_message -f Pipelet -c green"
  try {
    stage 'Downloading sources'
    git credentialsId: 'jenkins-ssh', url: 'git@github.com:Samsung-AG/kraken-services.git'
    stage 'Building and publishing images'
    docker.withServer('unix:///run/docker.sock') {

      stage 'Building load generator test service image'
      def framework = docker.build("samsung_ag/trogdor-framework:${env.BUILD_NUMBER}", "loadtest/build/web_service")
      stage 'Pushing load generator test service image'
      docker.withRegistry('https://quay.io/v1', 'quay-io') {
        framework.push()
        framework.push 'latest'
      }

      stage 'Building load generator image'
      def load_gen = docker.build("samsung_ag/trogdor-load-generator:${env.BUILD_NUMBER}", "loadtest/build/load_generator")
      stage 'Pushing load generator image'
      docker.withRegistry('https://quay.io/v1', 'quay-io') {
        load_gen.push()
        load_gen.push 'latest'
      }

      stage 'Building influxdb image'
      def influxdb = docker.build("samsung_ag/influxdb:${env.BUILD_NUMBER}", "influxdb-grafana/build/influxdb")
      stage 'Pushing influxdb image'
      docker.withRegistry('https://quay.io/v1', 'quay-io') {
        influxdb.push()
        influxdb.push 'latest'
      }

      stage 'Building grafana image'
      def grafana = docker.build("samsung_ag/grafana:${env.BUILD_NUMBER}", "influxdb-grafana/build/grafana")
      stage 'Pushing grafana image'
      docker.withRegistry('https://quay.io/v1', 'quay-io') {
        grafana.push()
        grafana.push 'latest'
      }

      stage 'Building podpincher image'
      def podpincher = docker.build("samsung_ag/podpincher:${env.BUILD_NUMBER}", "podpincher/build")
      stage 'Pushing podpincher image'
      docker.withRegistry('https://quay.io/v1', 'quay-io') {
        podpincher.push()
        podpincher.push 'latest'
      }

      stage 'Building prometheus image'
      def prometheus = docker.build("samsung_ag/prometheus:${env.BUILD_NUMBER}", "prometheus/build/prometheus")
      stage 'Pushing prometheus image'
      docker.withRegistry('https://quay.io/v1', 'quay-io') {
        prometheus.push()
        prometheus.push 'latest'
      }
    }
    sh "echo 'Kraken services build ${currentBuild.displayName} succeeded' | hipchat_room_message -f Pipelet -c green -n 1"
  } catch (e) {
    sh "echo 'Kraken services build ${currentBuild.displayName} failed with ${e.message}' | hipchat_room_message -f Pipelet -c red"
    throw e
  }
}