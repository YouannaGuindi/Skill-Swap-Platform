package com.ProjAdvAndWeb.model;
import java.sql.Timestamp;

public class Swap {
    private int swapId;
	private String requesterUsername;
	private String providerUsername;
    private int offeredSkillId;
	private Skill skillOffered; // The generic skill object details related to the swap
	private int pointsExchanged; // <-- This holds the point value for THIS specific swap request
	private SwapStatus status;
	private Timestamp requestDate;
	private Timestamp lastUpdatedDate;

    public Swap() {
    }

    // Getters and Setters
    public int getSwapId() {
        return swapId;
    }
    public void setSwapId(int swapId) {
        this.swapId = swapId;
    }

	public String getRequesterUsername() {
		return requesterUsername;
	}

	public void setRequesterUsername(String requesterUsername) {
		this.requesterUsername = requesterUsername;
	}

	public String getProviderUsername() {
		return providerUsername;
	}

	public void setProviderUsername(String providerUsername) {
		this.providerUsername = providerUsername;
	}

    public int getOfferedSkillId() {
        return offeredSkillId;
    }
    public void setOfferedSkillId(int offeredSkillId) {
        this.offeredSkillId = offeredSkillId;
    }

	public Skill getSkillOffered() {
		return skillOffered;
	}

	public void setSkillOffered(Skill skillOffered) {
		this.skillOffered = skillOffered;
	}

    // --- POINT LOGIC: Getter/Setter for the points value for THIS swap ---
	public int getPointsExchanged() {
        return pointsExchanged; // Returns the points set for this specific swap
    }
    public void setPointsExchanged(int pointsExchanged) {
        this.pointsExchanged = pointsExchanged; // Sets the points for this specific swap
    }
    // --- END POINT LOGIC ---

    public SwapStatus getStatus() {
        return status;
    }
    public void setStatus(SwapStatus status) {
        this.status = status;
    }

    public Timestamp getRequestDate() {
        return requestDate;
    }
    public void setRequestDate(Timestamp requestDate) {
        this.requestDate = requestDate;
    }

    public Timestamp getLastUpdatedDate() {
        return lastUpdatedDate;
    }
    public void setLastUpdatedDate(Timestamp lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }

	@Override
	public String toString() {
		return "Swap [swapId=" + swapId + ", requesterUsername=" + requesterUsername
				+ ", providerUsername=" + providerUsername + ", offeredSkillId=" + offeredSkillId
				+ ", skillOffered=" + (skillOffered != null ? skillOffered.getName() : "N/A") + ", pointsExchanged=" + pointsExchanged + ", status=" + status
				+ ", requestDate=" + requestDate + ", lastUpdatedDate=" + lastUpdatedDate + "]";
	}
}