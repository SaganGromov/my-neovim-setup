<code>
xhost +local:root

sudo docker build --network=host -t my-neovim-setup .

sudo docker run -it \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd)/nvim:/root/.config/nvim \
    my-neovim-setup
</code>
