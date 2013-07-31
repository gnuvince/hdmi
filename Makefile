hdmi: hdmi.hs
	ghc -O2 --make hdmi.hs

clean:
	rm -f hdmi hdmi.hi hdmi.o
