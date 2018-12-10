package model;

import java.util.Objects;

/** Represent a position. */
public class Position {

	/** X point. */
	private int x;
	/** Y point. */
	private int y;

	/**
	 * Constructor
	 * 
	 * @param thex
	 *            Position x point
	 * @param they
	 *            Position y point
	 */
	public Position(final int thex, final int they) {
		this.setX(thex);
		this.setY(they);

	}

	/**
	 * Gets x.
	 * 
	 * @return the x
	 */
	public int getX() {
		return x;
	}

	/**
	 * Sets x
	 * 
	 * @param thex
	 *            the x to set
	 */
	public void setX(final int x) {
		this.x = x;
	}

	/**
	 * Gets y.
	 * 
	 * @return the y
	 */
	public int getY() {
		return y;
	}

	/**
	 * Sets y
	 * 
	 * @param they
	 *            the y to set
	 */
	public void setY(final int y) {
		this.y = y;
	}

	@Override
	public boolean equals(final Object object) {
		if (object instanceof Position) {
			final Position otherPosition = (Position) object;
			return otherPosition.getX() == this.getX() && otherPosition.getY() == this.getY();
		} else {
			return false;
		}
	}

	@Override
	public int hashCode() {
		return Objects.hash(this.getX(), this.getY());
	}

	@Override
	public String toString() {
		return "(" + x + "," + y + ")";
	}

}
