package model;

/** Aggregation of events. */
public class AggregatedEvents {

	/** Total number of events. */
	private int totalEvents = 0;

	/**
	 * Increment number of events.
	 * 
	 * @param delta
	 *            Number to add
	 */
	public void incrementEvents(final int delta) {
		this.totalEvents = this.totalEvents + delta;
	}

	@Override
	public String toString() {
		return "[Total events = " + totalEvents + "]";
	}

}
