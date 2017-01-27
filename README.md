# Advenced Mobile Systems - iOS

Applications created in the laboratory Advanced Mobile System at AGH (University of Science and Technology) 

## Shoutbox app

### Requirements

**Functional**

The UI must be composed of a `Table View` (with a `Navigation Controller`) presenting the messages, and a „Compose” button in the right bar button items region.
Use the Subtitle style for table view cells.
The entries should be sorted by timestamp, newest first.
Each cell presents a single message:
the text label presents the relative timestamp in the format: „NNN minutes ago”
the detail text label presents the author and the message in the format: „Author says: Message text”
Messages are obtained from a HTTP backend, providing JSON-encoded data. (details below)
Pulling down on the table view refreshes the contents.
Tapping the Compose button opens a UIAlertController with a message and two text fields – one for the name and one for the message.

**Non-functional**

HTTP backend access must be performed using a third-party library. Recommended: `Alamofire`
„Pull to refresh” functionality must be performed using a third-party library. Recommended: `DGElasticPullToRefresh`
Third-party libraries must be installed using `CocoaPods`.
The app should use English as the base language and include at least one localisation in a language of your choice.
