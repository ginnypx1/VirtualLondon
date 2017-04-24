# Virtual London

"Virtual London" is an app developed to practice API, CoreData and UICollectionView work needed to complete the app "Virtual Tourist" for the Udacity iOS Nanodegree. It downloads recent Flickr photos taken near the Tower of London and allows user to view the photos, delete the ones they don't like, and save the ones they do.

## Install

To check out my version of "Virtual London":

1. Clone or download my repository:
` $ https://github.com/ginnypx1/VirtualLondon.git `

2. Enter the "Virtual London" directory:
` $ cd /VirtualLondon-master/ `

3. Open "Virtual London" in XCode:
` $ open VirtualLondon.xcodeproj `

To run the project in xCode, you will need to add a Private.swift file with your Flickr API key information:

```
let YOUR_API_KEY = <YOUR_API_KEY>
```

## Instructions

The app will automatically download the 21 most recent photos near the Tower of London in London, England that have been shared on Flickr. Tap on a photo to remove it from the set. Press the **New Collection** button at the bottom to fetch a new batch of photos.

## Technical Information

The Flickr API can be found at: https://www.flickr.com/services/api/

## Improvements

- Currently, tapping **New Collection** loads pretty much the same photos as before, unless the user has let some time pass. I'd like to fix that so it loads the next photos in the Flickr set.
- I would like to update the app to automatically replace deleted photos with new photos.
- I would like to add activity indicators to each photo in the Collection View as they load.