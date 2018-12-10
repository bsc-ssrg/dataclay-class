package model;

/**
 * Represents an event.
 */
public class Event {

	/** Event type. */
	private int type;

	/** Time stamp. NOTE: java DATE type currently not supported in dataClay. */
	private String timestamp;

	/** Position where the event happened. */
	private Position position;

	/**
	 * Event.
	 * 
	 * @param thetype
	 *            Event type
	 * @param thetimestamp
	 *            Time stamp
	 * @param theposition
	 *            Position where the event happened
	 */
	public Event(final int thetype, final String thetimestamp, final Position theposition) {
		this.setType(thetype);
		this.setTimestamp(thetimestamp);
		this.setPosition(theposition);
	}

	/**
	 * Gets type.
	 * 
	 * @return the type
	 */
	public int getType() {
		return type;
	}

	/**
	 * Sets type
	 * 
	 * @param thetype
	 *            the type to set
	 */
	public void setType(final int type) {
		this.type = type;
	}

	/**
	 * Gets timestamp.
	 * 
	 * @return the timestamp
	 */
	public String getTimestamp() {
		return timestamp;
	}

	/**
	 * Sets timestamp
	 * 
	 * @param thetimestamp
	 *            the timestamp to set
	 */
	public void setTimestamp(final String timestamp) {
		this.timestamp = timestamp;
	}

	/**
	 * Gets position.
	 * 
	 * @return the position
	 */
	public Position getPosition() {
		return position;
	}

	/**
	 * Sets position
	 * 
	 * @param theposition
	 *            the position to set
	 */
	public void setPosition(final Position position) {
		this.position = position;
	}

	@Override
	public String toString() {
		return "{EVENT at position=" + position.toString() + ", type=" + type + ", timestamp = " + timestamp + "}";
	}
}
