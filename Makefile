OUT=flappy_odin

debug:
	odin build ./src -debug -o:none -out:$(OUT)

release:
	odin build ./src -o:minimal -out:$(OUT)

clean:
	rm $(OUT)
