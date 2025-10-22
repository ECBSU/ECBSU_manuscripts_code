# MAFFT alignment automatic
D:\Uni\Programmes\mafft-win\mafft.bat --adjustdirection --auto --reorder "%%i" > "%%i.mafft"
# MAFFT alignment L-INS-i algorithm
D:\Uni\Programmes\mafft-win\mafft.bat --adjustdirection --localpair  --maxiterate 16 --reorder "%%i" > "%%i.mafft"

# trim with Gblocks
D:\Uni\Programmes\Gblocks_0.91b\Gblocks.exe "%%i.mafft_out.fas" 