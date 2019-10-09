package main

import (
  "fmt"
  "io/ioutil"
  "log"
  "net/http"
)

func testRun() error {
  endpoint := "test-deploy-nginx.default.svc.cluster.local"
  resp, err := http.Get(fmt.Sprintf("http://%s/", endpoint))
  if err != nil {
    return err
  }
  defer resp.Body.Close()
  body, err := ioutil.ReadAll(resp.Body)
  if err != nil {
    return err
  }
  log.Println(string(body))
  return nil
}

func main() {
  if err := testRun(); err == nil {
    log.Println("Test pass!")
  } else {
    log.Fatal(err)
  }
}
