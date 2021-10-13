OWNER="lyscm"
REGISTRY="ghcr.io"
REPOSITORY_NAME="environments/kali"
TAG="extensions"

echo $CR_PAT | docker login $REGISTRY -u $OWNER --password-stdin

cd $HOME/.vscode-server/$TAG/ && zip -9 -r $TAG.zip ./* && cd -

yes | cp -r $HOME/.vscode-server/$TAG/$TAG.zip .
rm -rf $HOME/.vscode-server/$TAG/$TAG.zip

docker buildx build \
    --output "type=image,push=true" \
    --file ./Dockerfile.$TAG \
    --tag $REGISTRY/$OWNER/$REPOSITORY_NAME/$TAG \
    .

rm -rf $TAG.zip