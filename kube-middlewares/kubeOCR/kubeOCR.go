package kubeOCR

//
// Luc Michalski - 2015
// Kube Vision = Kube OCR (Tessract with Stroke Width Transform for Dark Background)
// Optional: batch requests to entities extraction/disambiguation engine
//

// Note that I import the versions bundled with kube vproxy. That will make our lives easier, as we'll use exactly the same versions used
// by kube Vproxy. We are escaping dependency management troubles thanks to Godep.
import (
	"fmt"
	"github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/codegangsta/cli"
	"github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/vulcand/oxy/utils"
	"github.com/lepidosteus/golang-http-batch/batch"
	"github.com/disintegration/imaging"
	"github.com/vulcand/vulcand/plugin"
	"io"
	"log"
	"image"
	"bytes"
	"image/jpeg"
	"encoding/base64"
	"net/http"
	"strconv"
	"strings"
)

const Type = "kubeOCR"

func GetSpec() *plugin.MiddlewareSpec {
	return &plugin.MiddlewareSpec{
		Type:      Type,       // A short name for the middleware
		FromOther: FromOther,  // Tells kube vproxy how to rcreate middleware from another one (this is for deserialization)
		FromCli:   FromCli,    // Tells kube vproxy how to create middleware from command line tool
		CliFlags:  CliFlags(), // Kube Vproxy will add this flags to middleware specific command line tool
	}
}

type Options struct {
		Quality int
}

type bufferWriter struct {
	header http.Header
	code   int
	buffer *bytes.Buffer
}

func (b *bufferWriter) Close() error {
	return nil
}

func (b *bufferWriter) Header() http.Header {
	return b.header
}

func (b *bufferWriter) Write(buf []byte) (int, error) {
	return b.buffer.Write(buf)
}

// WriteHeader sets rw.Code.
func (b *bufferWriter) WriteHeader(code int) {
	b.code = code
}

var part1, part2, ocrImg, contentType, apiUrl string

// KubeOCRMiddleware struct holds configuration parameters and is used to
// serialize/deserialize the configuration from storage engines.
type KubeOCRMiddleware struct {
	MarkerId          int
	BlippId           int
	Context           string
	Width             int
	Height            int
	Timeout           int
	Transformation    string
	Chained           int
	Concurrency       int
	DetectDarkness    int
	OcrEngine         string
	OcrPreProcessors  string
	EntitiesExtractor string
	EntitiesDiscovery int
	Debug             int
}

// KubeOCR middleware handler
type KubeOCRHandler struct {
	cfg  KubeOCRMiddleware
	next http.Handler
}

type Output struct {
	Status int
	Result string
}

// This function will be called each time the request hits the location with this middleware activated
func (a *KubeOCRHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("X-Middleware-OCR", "KubeOCR")
    //io.WriteString(w, "OCR go")
	if a.cfg.Chained == 0 {
		a.next.ServeHTTP(w, r)
		return
	}

	contentType, err := utils.ParseAuthHeader(r.Header.Get("Content-Type"))

	file, _, err := r.FormFile("file")
	if err != nil {
	    
	    io.WriteString(w, "problem detected")
		a.next.ServeHTTP(w, r)
		return
	}

	img, formatImg, err := image.Decode(file)
	if err != nil {
	    
	    io.WriteString(w, "problem detected")
		a.next.ServeHTTP(w, r)
		return
	}

	if formatImg != "jpeg" {
	    
	    io.WriteString(w, "problem detected")
		a.next.ServeHTTP(w, r)
		return
	} else {
		log.Println("Go for processing")		
	}

	if a.cfg.Debug == 1 {
		log.Println("Format Type: ", formatImg)
		log.Println("BlippId: ", a.cfg.BlippId)
		log.Println("MarkerId: ", a.cfg.MarkerId)
		log.Println("Context: ", a.cfg.Context)
		log.Println("Timeout limit: ", a.cfg.Timeout)
		log.Println("Thumb Width: ", a.cfg.Width)
		log.Println("Thumb Height: ", a.cfg.Height)
		log.Println("Detect Darkness in Pictures: ", a.cfg.DetectDarkness)
		log.Println("Entities Discovery: ", a.cfg.EntitiesDiscovery)
		log.Println("Entities Extractor: ", a.cfg.EntitiesExtractor)
		log.Println("ContentType: ", contentType)
	}

	dstImage := img
	if a.cfg.Transformation != "" || (a.cfg.Width > 0 || a.cfg.Height > 0) {
		transformations := strings.Split(a.cfg.Transformation, ",")
		for _, transform := range transformations {
			cmds := strings.Split(string(transform), "=")
			if cmds[0] == "Blur" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.Blur(img, sigma)
			}
			if cmds[0] == "Sharpen" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.Sharpen(img, sigma)
			}
			if cmds[0] == "AdjustGamma" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.AdjustGamma(img, sigma)
			}
			if cmds[0] == "AdjustContrast" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.AdjustContrast(img, sigma)
			}
			if cmds[0] == "AdjustBrightness" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.AdjustBrightness(img, sigma)
			}
			if cmds[0] == "AdjustSigmoid" {
				midpoint, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				factor, err := strconv.ParseFloat(cmds[2], 64)
				if err != nil {
					log.Println("Error while decoding sigma: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.AdjustSigmoid(img, midpoint, factor)
			}
			if cmds[0] == "Grayscale" {
				dstImage = imaging.Grayscale(img)
			}
			if cmds[0] == "Invert" {
				dstImage = imaging.Invert(img)
			}
			if cmds[0] == "FlipH" {
				dstImage = imaging.FlipH(img)
			}
			if cmds[0] == "FlipH" {
				dstImage = imaging.FlipH(img)
			}
			if cmds[0] == "Crop" {
				x0, err := strconv.ParseInt(cmds[1], 0, 32)
				if err != nil {
					log.Println("Error while decoding x0 coordinates: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				y0, err := strconv.ParseInt(cmds[2], 0, 32)
				if err != nil {
					log.Println("Error while decoding y0 coordinates: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				x1, err := strconv.ParseInt(cmds[3], 0, 32)
				if err != nil {
					log.Println("Error while decoding x1 coordinates: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				y1, err := strconv.ParseInt(cmds[4], 0, 32)
				if err != nil {
					log.Println("Error while decoding the y1 coordinates: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.Crop(img, image.Rect(int(x0), int(y0), int(x1), int(y1)))
			}
			if cmds[0] == "CropCenter" {
				width, err := strconv.ParseInt(cmds[1], 0, 32)
				if err != nil {
					log.Println("Error while decoding the width value: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				height, err := strconv.ParseInt(cmds[1], 0, 32)
				if err != nil {
					log.Println("Error while decoding the height value: ", err)
				    
				    io.WriteString(w, "problem detected")
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.CropCenter(img, int(width), int(height))
			}
			//if cmds[0] == "Paste" {
			//	backgroundImage :=
			//	dstImage = imaging.Paste(backgroundImage, img, image.Pt(strconv.ParseFloat(cmds[1], 64), strconv.ParseFloat(cmds[2], 64)))
			//}
			//if cmds[0] == "PasteCenter" {
			//      backgroundImage :=
			//      dstImage = imaging.Paste(backgroundImage, img)
			//}
			//if cmds[0] == "Overlay" {
			//      backgroundImage :=
			//      dstImage = imaging.Overlay(backgroundImage, srcImage, image.Pt(strconv.ParseFloat(cmds[1], 64), strconv.ParseFloat(cmds[2], 64)), strconv.ParseFloat(cmds[3], 64))
			//}
			if cmds[0] == "Clone" {
				//copiedImg := imaging.Clone(img)
				if a.cfg.Debug == 1 {
					//log.Println("Content-Type: %T\n", dstImage)
				}
			}
			if cmds[0] == "Rotate" && cmds[1] == "180" {
				dstImage = imaging.Rotate180(img)
			}
			if cmds[0] == "Rotate" && cmds[1] == "270" {
				dstImage = imaging.Rotate270(img)
			}
			if cmds[0] == "Rotate" && cmds[1] == "90" {
				dstImage = imaging.Rotate90(img)
			}
			if cmds[0] == "Fit" || cmds[0] == "Resize" {
				dstImage = imaging.Fit(img, a.cfg.Width, a.cfg.Height, imaging.Lanczos)
			}
		}
	}

	buf := bytes.NewBuffer(nil)
	if err := jpeg.Encode(buf, dstImage, nil); err != nil {
		log.Println("Problem while trying to encode")
	    
	    io.WriteString(w, "problem detected")
		a.next.ServeHTTP(w, r)
		return
	}
 
	imgStr := base64.StdEncoding.EncodeToString(buf.Bytes())

	log.Println("apiUrl:", apiUrl)

	b := batch.New()
	b.SetMaxConcurrent(a.cfg.Concurrency)
	b.AddEntry("http://192.168.99.100:9292/ocr-file-upload", "POST", "tessaract", imgStr, batch.Callback(func(url string, method string, vengine string, payload string, body string, data batch.CallbackData, err error) {
		if err != nil {
			log.Println("Result from: ", url)
		}
		if len(body) > 5 {
			if a.cfg.Debug == 1 {
				log.Println("Result from: ", url)
				log.Println("Text extracted:", len(body))
				log.Println("Cumulated Characters Length (With Spaces):\n", body)
			}
			w.Header().Set("X-Kube-OCR-result", string(len(body)))
		}
	}))

	b.Run()
	a.next.ServeHTTP(w, r)
}

// Parse command line parameters; faster than regex
func StrExtract(sExper, sAdelim, sCdelim string, nOccur int) string {
	aExper := strings.Split(sExper, sAdelim)
	if len(aExper) <= nOccur {
		return ""
	}
	sMember := aExper[nOccur]
	aExper = strings.Split(sMember, sCdelim)
	if len(aExper) == 1 {
		return ""
	}
	return aExper[0]
}

// This function is optional but handy, used to check input parameters when creating new middlewares
func New(blippId int, markerId int, context string, width int, height int, timeout int, transformation string, chained int, concurrency int, detectDarkness int, ocrPreProcessors string, ocrEngine string, entitiesExtractor string, entitiesDiscovery int, debug int) (*KubeOCRMiddleware, error) {
	if ocrEngine == "" {
		return nil, fmt.Errorf("Template and endpoints url(s) list can not be empty")
	}
	return &KubeOCRMiddleware{BlippId: blippId, MarkerId: markerId, Context: context, Width: width, Height: height, Timeout: timeout, Transformation: transformation, Chained: chained, Concurrency: concurrency, DetectDarkness: detectDarkness, OcrPreProcessors: ocrPreProcessors, OcrEngine: ocrEngine, EntitiesExtractor: entitiesExtractor, EntitiesDiscovery: entitiesDiscovery, Debug: debug}, nil
}

// This function is important, it's called by kube vproxy to create a new handler from the middleware config and put it into the
// middleware chain. Note that we need to remember 'next' handler to call
func (c *KubeOCRMiddleware) NewHandler(next http.Handler) (http.Handler, error) {
	return &KubeOCRHandler{next: next, cfg: *c}, nil
}

// String() will be called by loggers inside Kube-Vproxy and command line tool.
func (c *KubeOCRMiddleware) String() string {
	return fmt.Sprintf("blippId=%v, markerId=%v, context=%v, width=%v, height=%v, timeout=%v, chained=%v, concurrency=%v, detectDarkness=%v,  ocrPreProcessors=%v, ocrPreProcessors=%v, ocrEngine=%v, entitiesExtractor=%v, entitiesDiscovery=%v, debug=%v", c.BlippId, c.MarkerId, c.Context, c.Width, c.Height, c.Timeout, c.Transformation, c.Chained, c.Concurrency, c.DetectDarkness, c.OcrPreProcessors, c.OcrEngine, c.EntitiesExtractor, c.EntitiesDiscovery, c.Debug)
}

// FromOther Will be called by Kube VProxy when engine or API will read the middleware from the serialized format.
// It's important that the signature of the function will be exactly the same, otherwise Kube vproxy will
// fail to register this middleware.
// The first and the only parameter should be the struct itself, no pointers and other variables.
// Function should return middleware interface and error in case if the parameters are wrong.
func FromOther(c KubeOCRMiddleware) (plugin.Middleware, error) {
	return New(c.BlippId, c.MarkerId, c.Context, c.Width, c.Height, c.Timeout, c.Transformation, c.Chained, c.Concurrency, c.DetectDarkness, c.OcrPreProcessors, c.OcrEngine, c.EntitiesExtractor, c.EntitiesDiscovery, c.Debug)
}

// FromCli constructs the middleware from the command line
func FromCli(c *cli.Context) (plugin.Middleware, error) {
	return New(c.Int("blippId"), c.Int("markerId"), c.String("context"), c.Int("width"), c.Int("height"), c.Int("timeout"), c.String("transformation"), c.Int("concurrency"), c.Int("Chained"), c.Int("detectDarkness"), c.String("ocrPreProcessors"), c.String("ocrEngine"), c.String("entitiesExtractor"), c.Int("entitiesDiscovery"), c.Int("debug"))
}

// CliFlags will be used by Kube Vproxy construct help and CLI command for the vctl command
func CliFlags() []cli.Flag {
	return []cli.Flag{
		cli.IntFlag{"blippId", 0, "BlippId", ""},
		cli.IntFlag{"markerId", 0, "MarkerId", ""},
		cli.StringFlag{"context", "", "Context", ""},
		cli.IntFlag{"width", 320, "Thumb Width", ""},
		cli.IntFlag{"height", 240, "Thumb Height", ""},
		cli.IntFlag{"timeout", 250, "timeout for the OCR processing", ""},
		cli.StringFlag{"transformation", "", "Contrast=20,Brightness=20,Gamma=0.75,Sharpen=0.5,Blur=0.5,Invert,GrayScale", ""},
		cli.IntFlag{"chained", 0, "Continue the chain of middlewares", ""},
		cli.IntFlag{"concurrency", 50, "Max Concurrent Requests", ""},
		cli.IntFlag{"detectDarkness", 0, "Detect dark pictures, dark backgrounds", ""},
		cli.StringFlag{"ocrPreProcessors", "stroke-width-transform=1", "Pre-processing the scene for black background images (0,1 or auto)", ""},
		cli.StringFlag{"ocrEngine", "engine=tesseract", "OCR Engines (Tessaract)", ""},
		cli.IntFlag{"entitiesExtractor", 0, "Try to do some text enrichment", ""},
		cli.StringFlag{"entitiesDiscovery", "", "Entities Discovery; wikidata=endpoint1,ner=endpoint2,stanbol=endpoint3,yago=endpoint4,aida=endpoint5,socialSensor=endpoint6", ""},
		cli.IntFlag{"debug", 0, "Debug Mode", ""},
	}
}
