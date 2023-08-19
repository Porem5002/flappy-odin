OUT=flappy_odin

debug:
	odin build ./src -debug -out:$(OUT)

release:
	odin build ./src -o:speed -out:$(OUT)

clean:
	rm $(OUT)
