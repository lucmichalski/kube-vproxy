package main

import (
  "flag"
  "fmt"
  "net/http"
  "os"
  "time"
  _ "expvar"
  _ "net/http/pprof"
)

// Job holds the attributes needed to perform unit of work.
type Job struct {
  Name  string
  Delay time.Duration
}

// NewWorker creates takes a numeric id and a channel w/ worker pool.
func NewWorker(id int, jobQueue chan Job) Worker {
  return Worker{
    id:         id,
    jobQueue:   jobQueue,
    quitChan:   make(chan bool),
  }
}

type Worker struct {
  id         int
  jobQueue   chan Job
  quitChan   chan bool
}

func (w Worker) start() {
  go func() {
    for {
      select {
      case job := <-w.jobQueue:
        // Dispatcher has added a job to my jobQueue.
        fmt.Printf("worker%d: started %s, blocking for %f seconds\n", w.id, job.Name, job.Delay.Seconds())
        time.Sleep(job.Delay)
        fmt.Printf("worker%d: completed %s!\n", w.id, job.Name)
      }
    }
  }()
}

func requestHandler(w http.ResponseWriter, r *http.Request, jobQueue chan Job) {
  // Make sure we can only be called with an HTTP POST request.
  if r.Method != "POST" {
    w.Header().Set("Allow", "POST")
    w.WriteHeader(http.StatusMethodNotAllowed)
    return
  }

  // Parse the delay.
  delay, err := time.ParseDuration(r.FormValue("delay"))
  if err != nil {
    http.Error(w, "Bad delay value: "+err.Error(), http.StatusBadRequest)
    return
  }

  // Validate delay is in range 1 to 10 seconds.
  if delay.Seconds() < 1 || delay.Seconds() > 10 {
    http.Error(w, "The delay must be between 1 and 10 seconds, inclusively.", http.StatusBadRequest)
    return
  }

  // Set name and validate value.
  name := r.FormValue("name")
  if name == "" {
    http.Error(w, "You must specify a name.", http.StatusBadRequest)
    return
  }

  // Create Job and push the work onto the jobQueue.
  job := Job{Name: name, Delay: delay}
  go func() {
    jobQueue <- job
  }()

  // Render success.
  w.WriteHeader(http.StatusCreated)
  return
}

func main() {
  // Parse the command-line flags.
  maxWorkers := flag.Int("max_workers", 5, "The number of workers to start")
  maxQueueSize := flag.Int("max_queue_size", 100, "The size of job queue")
  flag.Parse()

  // Create the job queue.
  jobQueue := make(chan Job, *maxQueueSize)

  // Start the dispatcher.
  for i := 0; i < *maxWorkers; i++ {
    worker := NewWorker(i, jobQueue)
    worker.start()
  }

  // Start the HTTP handler.
  http.HandleFunc("/work", func(w http.ResponseWriter, r *http.Request) {
    requestHandler(w, r, jobQueue)
  })
  http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}
