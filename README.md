# abc-step-1000

The first 1000 STEP files from the [ABC dataset](https://deep-geometry.github.io/abc-dataset/),
hosted on GitHub Pages for convenient direct download.

- **Browse:** https://concept-collection.github.io/abc-step-1000/
- **Manifest:** https://concept-collection.github.io/abc-step-1000/index.json

The files are served gzip-compressed (`.step.gz`, ~300 MB total; ~1.6 GB
uncompressed). `index.json` lists every file with its download path, model ID,
and compressed/uncompressed sizes.

## Downloading

A single file:

```sh
curl -sL https://concept-collection.github.io/abc-step-1000/step/00000002_1ffb81a71e5b402e966b9341_step_001.step.gz \
  | gunzip > model.step
```

All files, using the manifest:

```sh
BASE=https://concept-collection.github.io/abc-step-1000
curl -sL $BASE/index.json | jq -r '.files[].path' \
  | xargs -P 8 -I{} sh -c 'curl -sL "$1/$2" | gunzip > "$(basename "$2" .gz)"' _ $BASE {}
```

In the browser, decompress with
[`DecompressionStream`](https://developer.mozilla.org/en-US/docs/Web/API/DecompressionStream):

```js
const res = await fetch(url);
const step = await new Response(
  res.body.pipeThrough(new DecompressionStream('gzip'))
).text();
```

## How it is built

The GitHub Actions workflow ([deploy.yml](.github/workflows/deploy.yml))
downloads the first chunk of the STEP format (`abc_0000_step_v00.7z`, ~1.6 GB),
extracts the first 1000 model directories, gzips each `.step` file, generates
`index.json`, and deploys the result to GitHub Pages. The content is a fixed
slice of the dataset, so the workflow runs on manual dispatch only.

## Source and acknowledgments

All CAD models come from the **ABC dataset**:

> Koch, Sebastian and Matveev, Albert and Jiang, Zhongshi and Williams, Francis
> and Artemov, Alexey and Burnaev, Evgeny and Alexa, Marc and Zorin, Denis and
> Panozzo, Daniele. *ABC: A Big CAD Model Dataset For Geometric Deep Learning.*
> CVPR 2019.

```bibtex
@InProceedings{Koch_2019_CVPR,
  author = {Koch, Sebastian and Matveev, Albert and Jiang, Zhongshi and Williams, Francis and Artemov, Alexey and Burnaev, Evgeny and Alexa, Marc and Zorin, Denis and Panozzo, Daniele},
  title = {ABC: A Big CAD Model Dataset For Geometric Deep Learning},
  booktitle = {The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  month = {June},
  year = {2019}
}
```

Please cite the paper if you use these models. The ABC dataset authors are
grateful to [Onshape](https://www.onshape.com/) for providing the CAD models
and support.

The copyright of the CAD models is owned by their creators; for licensing
details see the
[Onshape Terms of Use 1.g.ii](https://www.onshape.com/en/legal/terms-of-use#your_content).
The dataset authors give no warranties regarding the dataset.
