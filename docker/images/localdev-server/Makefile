VERSION = $(shell date +v%Y%m%d)-$(shell git describe --tags --always --dirty)

IMG = "gamerson/localdev"

all: image

image:
	docker build -t "$(IMG):$(VERSION)" .
	docker tag "$(IMG):$(VERSION)" "$(IMG):latest" 

push: image
	gcloud docker -- push "$(IMG):$(VERSION)"

.PHONY: all image push
