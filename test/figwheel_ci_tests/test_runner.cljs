(ns figwheel-ci-tests.test-runner
  (:require
    ;; require all the namespaces that you want to test
    [figwheel.main.testing :refer-macros [run-tests-async]]
    [figwheel-ci-tests.figwheel-ci-tests-test :as figwheel-ci-tests]))


(defn -main
  [& _args]
  ;; this needs to be the last statement in the main function so that it can
  ;; return the value `[:figwheel.main.async-result/wait 10000]`.  `app-testing`
  ;; is a reference to a DOM id on the testing page
  (println "Run main script ")
  (run-tests-async 5000))
