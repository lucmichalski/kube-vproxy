package kubeLogos

//
// Luc Michalski - 2015
// Kube Vision
//

// Note that I import the versions bundled with kube vproxy. That will make our lives easier, as we'll use exactly the same versions used
// by kube Vproxy. We are escaping dependency management troubles thanks to Godep.
import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/davidkbainbridge/jsonq" 
	"github.com/lepidosteus/golang-http-batch/batch"
	"github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/codegangsta/cli"
	"github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/vulcand/oxy/utils"
	"github.com/vulcand/vulcand/plugin"
	"github.com/disintegration/imaging"	
	"image"
	"log"
	"time"
	"image/jpeg"
	"net/http"
	"strconv"
	"strings"
)

const Type = "kubeLogos"

func GetSpec() *plugin.MiddlewareSpec {
	return &plugin.MiddlewareSpec{
		Type:      Type,       // A short name for the middleware
		FromOther: FromOther,  // Tells kube vproxy how to rcreate middleware from another one (this is for deserialization)
		FromCli:   FromCli,    // Tells kube vproxy how to create middleware from command line tool
		CliFlags:  CliFlags(), // Kube Vproxy will add this flags to middleware specific command line tool
	}
}

// KubeLogosMiddleware struct holds configuration parameters and is used to
// serialize/deserialize the configuration from storage engines.
type KubeLogosMiddleware struct {
	Template       string
	Queue          string
	MarkerId       int
	BlippId        int
	Context        string
	Width          int
	Height         int
	Learn          int
	Nudity         string
	Discovery      string
	Transformation string
	Concurrency    int
	Chained        int
	MinScore       float64
	ParseScore     string
	ParseBB        string
	ParseMeta      string
	ActiveEngines  string
	Debug          int
}

type Output struct {
	Status int
	Result []string
}

type bufferWriter struct {
	header http.Header
	code   int
	buffer *bytes.Buffer
}

// KubeLogos middleware handler
type KubeLogosHandler struct {
	cfg  KubeLogosMiddleware
	next http.Handler
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

// This function will be called each time the request hits the location with this middleware activated
func (a *KubeLogosHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("X-Middleware-LOGOS-START",  strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
	if a.cfg.Chained == 0 {
		w.Header().Set("KubeVision_LOGOS_LOG_SKIPPED_BY_CONFIG", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		log.Println("KubeVision_LOGOS_LOG_SKIPPED_BY_CONFIG, ", "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					    
		a.next.ServeHTTP(w, r)
		return
	}

	// Check that mor ein depth
	contentType, err := utils.ParseAuthHeader(r.Header.Get("Content-Type"))

	file, _, err := r.FormFile("file")
	if err != nil {
		w.Header().Set("KubeVision_LOGOS_ERROR_NO_INPUT", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		log.Println("KubeVision_LOGOS_ERROR_NO_INPUT:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))			    
		a.next.ServeHTTP(w, r)
		return
	}

	img, formatImg, err := image.Decode(file)
	if err != nil {
		w.Header().Set("KubeVision_LOGOS_ERROR_DECODE_INPUT_FORMAT", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		log.Println("KubeVision_LOGOS_ERROR_DECODE_INPUT_FORMAT:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					    
		a.next.ServeHTTP(w, r)
		return
	}

	if formatImg != "jpeg" {	    
		w.Header().Set("KubeVision_LOGOS_ERROR_INVALID_INPUT_FORMAT", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		log.Println("KubeVision_LOGOS_ERROR_INVALID_INPUT_FORMAT:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	   
		a.next.ServeHTTP(w, r)
		return
	} else {
		w.Header().Set("KubeVision_LOGOS_LOG_VALID_INPUT_FORMAT", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		log.Println("KubeVision_LOGOS_LOG_VALID_INPUT_FORMAT:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
	}

	if a.cfg.Debug == 1 {
		log.Println("KubeVision_LOGOS_LOG_FORMAT_TYPE:", formatImg, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_BLIPP_ID:", a.cfg.BlippId, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_MARKER_ID:", a.cfg.MarkerId, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_CONTEXT:", a.cfg.Context, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_THUMB_WIDTH:", a.cfg.Width, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_THUMB_HEIGHT:", a.cfg.Height, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_LEARNING_MODE:", a.cfg.Learn, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_CHAIN:", a.cfg.Queue, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
		log.Println("KubeVision_LOGOS_LOG_CONTENT_TYPE:", contentType, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
	}

	// Need to create a package or method for all image processing
	dstImage := img
	if a.cfg.Transformation != "" || (a.cfg.Width > 0 || a.cfg.Height > 0) {
		transformations := strings.Split(a.cfg.Transformation, ",")
		if a.cfg.Debug == 1 {
			w.Header().Set("KubeVision_LOGOS_LOG_IMG_PROCESSING_CHAIN_START", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
			w.Header().Set("KubeVision_LOGOS_LOG_IMG_PROCESSING_LENCHAIN", strconv.Itoa(len(transformations)))
			log.Println("KubeVision_LOGOS_LOG_IMG_PROCESSING_START:", "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10), "lenght:", len(transformations))
		}
		for _, transform := range transformations {
			cmds := strings.Split(string(transform), "=")
			if a.cfg.Debug == 1 {
				w.Header().Set("KubeVision_LOGOS_LOG_IMG_PROCESSING", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
				w.Header().Set("KubeVision_LOGOS_LOG_IMG_PROCESSING_CMD", cmds[0])
				log.Println("KubeVision_LOGOS_LOG_IMG_PROCESSING_CMD:", cmds[0], "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))																				
			}
			if cmds[0] == "Blur" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				w.Header().Set("KubeVision_LOGOS_LOG_IMG_BLUR_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				log.Println("KubeVision_LOGOS_LOG_IMG_BLUR_SIGMA:", sigma, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_BLUR_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_LOGOS_ERROR_IMG_BLUR_SIGMA:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))			    
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.Blur(img, sigma)
			}
			if cmds[0] == "Sharpen" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				w.Header().Set("KubeVision_LOGOS_LOG_IMG_SHARPEN_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				log.Println("KubeVision_LOGOS_LOG_IMG_SHARPEN_SIGMA:", sigma, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
				if err != nil {					
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_SHARPEN_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_LOGOS_ERROR_IMG_SHARPEN_SIGMA:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.Sharpen(img, sigma)
			}
			if cmds[0] == "AdjustGamma" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				w.Header().Set("KubeVision_LOGOS_LOG_IMG_ADJUST-GAMMA_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				log.Println("KubeVision_LOGOS_LOG_IMG_ADJUST-GAMMA_SIGMA:", sigma, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))	
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_ADJUST-GAMMA_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))															
					log.Println("KubeVision_LOGOS_ERROR_IMG_ADJUST-GAMMA_SIGMA:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.AdjustGamma(img, sigma)
			}
			if cmds[0] == "AdjustContrast" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_ADJUST-CONTRAST_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))										
					log.Println("KubeVision_LOGOS_ERROR_IMG_ADJUST-CONTRAST_SIGMA", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
				}
				dstImage = imaging.AdjustContrast(img, sigma)
			}
			if cmds[0] == "AdjustBrightness" {
				sigma, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_ADJUST-BRIGHTNESS_SIGMA", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_ADJUST-BRIGHTNESS_SIGMA:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.AdjustBrightness(img, sigma)
			}
			if cmds[0] == "AdjustSigmoid" {
				midpoint, err := strconv.ParseFloat(cmds[1], 64)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_ADJUST-SIGMOID_MIDPOINT", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_LOGOS_ERROR_IMG_ADJUST-SIGMOID_MIDPOINT:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
					return
				}
				factor, err := strconv.ParseFloat(cmds[2], 64)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_ADJUST-SIGMOID_FACTOR", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_LOGOS_ERROR_IMG_ADJUST-SIGMOID_FACTOR", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
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
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_CROP_X0", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_CROP_X0; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
					return
				}
				y0, err := strconv.ParseInt(cmds[2], 0, 32)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_CROP_Y0", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_CROP_Y0; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					a.next.ServeHTTP(w, r)
					return
				}
				x1, err := strconv.ParseInt(cmds[3], 0, 32)
				if err != nil {					
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_CROP_X1", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_CROP_X1; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))										
					a.next.ServeHTTP(w, r)
					return
				}
				y1, err := strconv.ParseInt(cmds[4], 0, 32)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_CROP_Y1", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_CROP_Y1; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))																				
					a.next.ServeHTTP(w, r)
					return
				}
				dstImage = imaging.Crop(img, image.Rect(int(x0), int(y0), int(x1), int(y1)))
			}
			if cmds[0] == "CropCenter" {
				width, err := strconv.ParseInt(cmds[1], 0, 32)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_CROP-CENTER_WIDTH", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_CROP-CENTER_WIDTH; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))																				
					a.next.ServeHTTP(w, r)
					return
				}
				height, err := strconv.ParseInt(cmds[1], 0, 32)
				if err != nil {
					w.Header().Set("KubeVision_LOGOS_ERROR_IMG_CROP-CENTER_HEIGHT", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
					log.Println("KubeVision_LOGOS_ERROR_IMG_CROP-CENTER_HEIGHT; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))																				
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
		w.Header().Set("KubeVision_LOGOS_LOG_IMG_PROCESSING_CHAIN_END", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
	}

	buf := bytes.NewBuffer(nil)
	if err := jpeg.Encode(buf, dstImage, nil); err != nil {
		w.Header().Set("KubeVision_LOGOS_ERROR_JPEGENCODE", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
		log.Println("KubeVision_LOGOS_ERROR_JPEGENCODE; ", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))																				
		a.next.ServeHTTP(w, r)
		return
	}
 
	imgStr := "data:image/jpeg;base64," + base64.StdEncoding.EncodeToString(buf.Bytes())

	// Condition for Payloads
	payLoad, err := base64.StdEncoding.DecodeString(a.cfg.Template)
	payLoadString := string(payLoad[:])
	payLoaded := strings.Replace(payLoadString, "ImageBase64", imgStr, 1)

	if a.cfg.Learn == 1 {
		payLoaded = strings.Replace(payLoaded, "learn_mode\":false", "learn_mode\":true", 1)
		if a.cfg.Debug == 1 {
			w.Header().Set("KubeVision_LOGOS_LOG_LEARNING_MODE_ACTIVATED", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))					
			log.Println("KubeVision_LOGOS_LOG_LEARNING_MODE_ACTIVATED; ", "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		}
	}

	if a.cfg.Debug == 1 {
		//log.Println("JSON Payload:\n", payLoaded)
		log.Println("Max Concurrency: ", a.cfg.Concurrency)
		log.Println("parseScore global rules: ", a.cfg.ParseScore)
		log.Println("parseMeta global rules: ", a.cfg.ParseMeta)
		log.Println("parseBB global rules: ", a.cfg.ParseBB)
	}

	if a.cfg.Discovery == "BATCH" {
		b := batch.New()
		b.SetMaxConcurrent(a.cfg.Concurrency)
		endpoints := strings.Split(a.cfg.Queue, "|")
		for _, endpoint := range endpoints {
			ep := strings.Split(endpoint, ":")
			if a.cfg.Debug == 1 {
				log.Println("Endpoint Protocol: ", ep[0])
				log.Println("Endpoint Type: ", ep[1])
				log.Println("Endpoint Url: ", ep[2])
				log.Println("Endpoint Port: ", ep[3])
			}
			b.AddEntry(string("http:"+ep[2]+":"+ep[3]), string(ep[0]), string(ep[1]), string(payLoaded), batch.Callback(func(url string, method string, vengine string, payload string, body string, data batch.CallbackData, err error) {
				if err != nil {
					w.Header().Set("KubeVision_BATCH_BODY_ERROR", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_BODY_ERROR:", err, "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))			    
				}
				if a.cfg.Debug == 1 {
					log.Println("KubeVision_BATCH_BODY_OK;", "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_BODY_LENGTH:", len(body), "at: ", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					w.Header().Set("KubeVision_BATCH_BODY_LENGTH", strconv.Itoa(len(body)))
					w.Header().Set("KubeVision_BATCH_BODY_OK", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				}
				scoreParse := StrExtract(a.cfg.ParseScore, vengine+"=", "|", 1)
				metaParse := StrExtract(a.cfg.ParseMeta, vengine+"=", "|", 1)
				bbParse := StrExtract(a.cfg.ParseBB, vengine+"=", "|", 1)
				if a.cfg.Debug == 1 {
					w.Header().Set("KubeVision_BATCH_SCORE_PARSING_RULES", scoreParse)
					w.Header().Set("KubeVision_BATCH_META_PARSING_RULES", metaParse)
					w.Header().Set("KubeVision_BATCH_BBOX_PARSING_RULES", bbParse)
					log.Println("KubeVision_BATCH_SCORE_PARSING_RULES:", scoreParse, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_META_PARSING_RULES:", metaParse, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_BBOX_PARSING_RULES:", bbParse, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				}
				ret := map[string]interface{}{}
				dec := json.NewDecoder(strings.NewReader(body))
				dec.Decode(&ret)
				jq := jsonq.NewQuery(ret)
				score, error := jq.Float(scoreParse)
				if error != nil {
					w.Header().Set("KubeVision_BATCH_ERROR_PARSING_SCORE", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_ERROR_PARSING_SCORE:", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				}
				if a.cfg.Debug == 1 {
					w.Header().Set("KubeVision_BATCH_SCORE", fmt.Sprintf("%v", score))
					log.Println("KubeVision_BATCH_SCORE; ", score, " on, ", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				}
				bb, error := jq.Array(bbParse)
				if error != nil {
					w.Header().Set("KubeVision_BATCH_ERROR_PARSING_BBOX", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_ERROR_PARSING_BBOX:", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				} else {
					if a.cfg.Debug == 1 {
						w.Header().Set("KubeVision_BATCH_BBOX", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
						log.Println("KubeVision_BATCH_BBOX; ", bb, " on, ", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					}
				}
				meta, error := jq.String(metaParse)
				if error != nil {
					w.Header().Set("KubeVision_BATCH_ERROR_PARSING_NAMED_ENTITY", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					log.Println("KubeVision_BATCH_ERROR_PARSING_NAMED_ENTITY:", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				} else {
					if a.cfg.Debug == 1 {
						w.Header().Set("KubeVision_BATCH_META", strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
						log.Println("KubeVision_BATCH_META; ", meta, " on, ", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
					}
				}
				if score > a.cfg.MinScore {
					// Headers for Middlewares
					w.Header().Set("X-Kube-VMX-Model", fmt.Sprintf("%v", meta))
					w.Header().Set("X-Kube-VMX-Matched", fmt.Sprintf("%f|%v|%v", score, a.cfg.MarkerId, meta))
					w.Header().Set("X-Kube-MarkerId", fmt.Sprintf("%v", a.cfg.MarkerId))
					w.Header().Set("X-Kube-VMX-Score", fmt.Sprintf("%v", score))
				} else {
					modelMissed := fmt.Sprintf("X-Kube-Missed-%v-%v", vengine, meta)
					w.Header().Set(fmt.Sprintf("%v", modelMissed), fmt.Sprintf("%v", score))
					log.Println("KubeVision_BATCH_NOK; ", meta, " on, ", vengine, strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
				}

			}))
		}
		endpointsNb := len(endpoints) 
		if a.cfg.Debug == 1 {
			w.Header().Set("KubeVision_BATCH_BINDINGS", fmt.Sprintf("%v", endpointsNb))
			log.Println("KubeVision_BATCH_BINDINGS ", fmt.Sprintf("%v", endpointsNb), strconv.FormatInt(time.Now().UTC().UnixNano(), 10))
		}
		b.Run()
	}
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
func New(template string, queue string, blippId int, markerId int, context string, width int, height int, learn int, nudity string, discovery string, transformation string, concurrency int, chained int, minScore float64, parseScore string, parseMeta string, parseBB string, activeEngines string, debug int) (*KubeLogosMiddleware, error) {
	if template == "" || queue == "" || markerId == 0 {
		return nil, fmt.Errorf("Template and endpoints url(s) list can not be empty")
	}
	return &KubeLogosMiddleware{Template: template, Queue: queue, BlippId: blippId, MarkerId: markerId, Context: context, Width: width, Height: height, Learn: learn, Nudity: nudity, Discovery: discovery, Transformation: transformation, Concurrency: concurrency, Chained: chained, MinScore: minScore, ParseScore: parseScore, ParseMeta: parseMeta, ParseBB: parseBB, ActiveEngines: activeEngines, Debug: debug}, nil
}

// This function is important, it's called by kube vproxy to create a new handler from the middleware config and put it into the
// middleware chain. Note that we need to remember 'next' handler to call
func (c *KubeLogosMiddleware) NewHandler(next http.Handler) (http.Handler, error) {

	return &KubeLogosHandler{next: next, cfg: *c}, nil
}

// String() will be called by loggers inside Kube-Vproxy and command line tool.
func (c *KubeLogosMiddleware) String() string {
	return fmt.Sprintf("template=%v, queue=%v, blippId=%v, markerId=%v, context=%v, width=%v, height=%v, learn=%v, nudity=%v, discovery=%v, concurrency=%v, chained=%v, minScore=%v, parseScore=%v, parseMeta=%v, parseBB=%v, activeEngines=%v, debug=%v", c.Template, c.Queue, c.BlippId, c.MarkerId, c.Context, c.Width, c.Height, c.Learn, c.Nudity, c.Discovery, c.Transformation, c.Concurrency, c.Chained, c.MinScore, c.ParseScore, c.ParseMeta, c.ParseBB, c.ActiveEngines, c.Debug)
}

// FromOther Will be called by Kube VProxy when engine or API will read the middleware from the serialized format.
// It's important that the signature of the function will be exactly the same, otherwise Kube vproxy will
// fail to register this middleware.
// The first and the only parameter should be the struct itself, no pointers and other variables.
// Function should return middleware interface and error in case if the parameters are wrong.
func FromOther(c KubeLogosMiddleware) (plugin.Middleware, error) {
	return New(c.Template, c.Queue, c.BlippId, c.MarkerId, c.Context, c.Width, c.Height, c.Learn, c.Nudity, c.Discovery, c.Transformation, c.Concurrency, c.Chained, c.MinScore, c.ParseScore, c.ParseMeta, c.ParseBB, c.ActiveEngines, c.Debug)
}

// FromCli constructs the middleware from the command line
func FromCli(c *cli.Context) (plugin.Middleware, error) {
	return New(c.String("template"), c.String("queue"), c.Int("blippId"), c.Int("markerId"), c.String("context"), c.Int("width"), c.Int("height"), c.Int("learn"), c.String("nudity"), c.String("discovery"), c.String("transformation"), c.Int("concurrency"), c.Int("chained"), c.Float64("minScore"), c.String("parseScore"), c.String("parseMeta"), c.String("parseBB"), c.String("activeEngines"), c.Int("Debug"))
}

// CliFlags will be used by Kube Vproxy construct help and CLI command for the vctl command
func CliFlags() []cli.Flag {
	return []cli.Flag{
		cli.StringFlag{"template", "", "JSON template payload encoded in base64", ""},
		cli.StringFlag{"queue", "", "Queue of Endpoints List + hash", ""},
		cli.IntFlag{"blippId", 0, "BlippId", ""},
		cli.IntFlag{"markerId", 0, "MarkerId", ""},
		cli.StringFlag{"context", "", "Context", ""},
		cli.IntFlag{"width", 320, "Thumb Width", ""},
		cli.IntFlag{"height", 240, "Thumb Height", ""},
		cli.IntFlag{"learn", 0, "Learn Mode", ""},
		cli.StringFlag{"nudity", "detect", "Nudity detection: block, detect or empty", ""},
		cli.StringFlag{"discovery", "BATCH", "Type: BATCH,CHANNEL,DYNRR,DYNPERF,CACHE,REGION", ""},
		cli.StringFlag{"transformation", "", "Contrast=20,Brightness=20,Gamma=0.75,Sharpen=0.5,Blur=0.5", ""},
		cli.IntFlag{"concurrency", 50, "Max Concurrent Requests", ""},
		cli.IntFlag{"chained", 0, "Continue the chain of middlewares", ""},
		cli.IntFlag{"minScore", 0, "Minimum Score for acceptance", ""},
		cli.StringFlag{"parseScore", "", "Parse results patterns, separate engine with delimiter pipe", ""},
		cli.StringFlag{"parseMeta", "", "dddw", ""},
		cli.StringFlag{"parseBB", "", "ddd", ""},
		cli.StringFlag{"activeEngines", "vmx2,vmx,ltu763", "Active Engines (Seprated by commas)", ""},
		cli.IntFlag{"debug", 0, "Debug Mode", ""},
	}
}
