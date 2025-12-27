<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><c:out value="${pageTitle != null ? pageTitle : 'Initiate Swap'}"/></title>
    <%-- Basic CSS for demonstration. You should use your form_styles.css --%>
    <style>
        body { font-family: 'Poppins', sans-serif; background-color: #f4f7f9; margin: 0; padding: 20px; display: flex; justify-content: center; align-items: flex-start; min-height: 100vh; }
        .form-container { background-color: #fff; padding: 30px 40px; border-radius: 12px; box-shadow: 0 8px 25px rgba(0,0,0,0.1); width: 100%; max-width: 600px; }
        .form-container h1 { color: #2c3e50; margin-bottom: 25px; text-align: center; font-size: 1.8em; }
        .form-container div { margin-bottom: 20px; }
        .form-container label { display: block; margin-bottom: 8px; font-weight: 500; color: #34495e; }
        .form-container select, .form-container input[type="number"] {
            width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 1em;
        }
        .form-container select:focus, .form-container input[type="number"]:focus {
            outline: none; border-color: #3498db; box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }
        .form-container button[type="submit"] {
            display: block; width: 100%; padding: 12px; background-color: #2ecc71; color: white; border: none;
            border-radius: 6px; font-size: 1.1em; font-weight: 600; cursor: pointer; transition: background-color 0.2s;
        }
        .form-container button[type="submit"]:hover { background-color: #27ae60; }
        .form-container small { display: block; margin-top: 5px; font-size: 0.85em; color: #7f8c8d; }
        .form-container .back-link { display: block; text-align: center; margin-top: 25px; color: #3498db; text-decoration: none; font-weight: 500; }
        .form-container .back-link:hover { text-decoration: underline; }
        .message, .error { padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: center; }
        .message { background-color: #e6fff3; color: #00642e; border: 1px solid #b3ffda;}
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}
        #skillRequestedId:disabled { background-color: #f0f0f0; cursor: not-allowed; }
    </style>
</head>
<body>
    <div class="form-container">
        <h1><c:out value="${pageTitle != null ? pageTitle : 'Request a Skill Swap'}"/></h1>

        <c:if test="${not empty requestScope.message || not empty param.message}">
            <p class="message"><c:out value="${requestScope.message}"/><c:out value="${param.message}"/></p>
        </c:if>
        <c:if test="${not empty requestScope.errorMessage}">
            <p class="error"><c:out value="${requestScope.errorMessage}"/></p>
        </c:if>

        <form action="${pageContext.request.contextPath}/swaps" method="POST">
            <input type="hidden" name="action" value="initiate"/> <%-- Ensure this matches SwapServlet --%>

            <div>
                <label for="providerUsername">Select User to Request From (Provider):</label>
                <select id="providerUsername" name="providerUsername" required> <%-- Changed name to providerUsername --%>
                    <option value="">-- Select Provider --</option>
                    <c:forEach var="user" items="${allOtherUsers}">
                        <option value="${user.username}" ${param.prefillProvider eq user.username ? 'selected' : ''}>
                            <c:out value="${user.firstName} ${user.lastName} (${user.username})"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div>
                <label for="skillRequestedId">Skill You Want to Learn:</label>
                <select id="skillRequestedId" name="skillRequestedId" required disabled>
                    <option value="">-- Select Provider First --</option>
                    <%-- Options will be populated by JavaScript --%>
                </select>
                <small id="skillSelectHelpText">Select a provider to see their offered skills.</small>
            </div>

            <div>
                <label for="pointsOffered">Points You Offer:</label>
                <input type="number" id="pointsOffered" name="pointsOffered" required min="1" value="10"/>
            </div>

            <div>
                <button type="submit">Send Swap Request</button>
            </div>
        </form>
        <p class="back-link"><a href="${pageContext.request.contextPath}/DashboardServlet">Back to Dashboard</a></p>
    </div>

<script>
    const providerSelect = document.getElementById('providerUsername');
    const skillSelect = document.getElementById('skillRequestedId');
    const skillHelpText = document.getElementById('skillSelectHelpText');

    console.log('Script start -- vULTRA_FINAL_CORRECTED'); // New version marker

    const prefillSkillId = "<c:out value='${param.prefillSkillId}' default=''/>";
    const prefillProviderUsername = "<c:out value='${providerUsernameValue}' default=''/>";
    const prefillSkillRequestedId = "<c:out value='${skillRequestedIdValue}' default=''/>";
    const prefillPointsOffered = "<c:out value='${pointsOfferedValue}' default='10'/>";

    console.log('Prefills: providerUsernameValue=' + prefillProviderUsername +
                ', skillRequestedIdValue=' + prefillSkillRequestedId +
                ', pointsOfferedValue=' + prefillPointsOffered +
                ', param.prefillSkillId=' + prefillSkillId);

    if (prefillProviderUsername && providerSelect) {
        providerSelect.value = prefillProviderUsername;
        console.log('Provider username prefilled to:', prefillProviderUsername);
    }
    if (prefillPointsOffered) {
        const pointsInput = document.getElementById('pointsOffered');
        if (pointsInput) pointsInput.value = prefillPointsOffered;
        console.log('Points offered prefilled to:', prefillPointsOffered);
    }

    function fetchAndPopulateSkills() {
        const selectedProviderUsername = providerSelect.value;
        console.log('fetchAndPopulateSkills CALLED. Provider:', selectedProviderUsername);

        skillSelect.innerHTML = '<option value="">Loading skills...</option>';
        skillSelect.disabled = true;
        console.log('Skill select DISABLED (start of fetch)');
        skillHelpText.textContent = 'Fetching skills...';

        if (selectedProviderUsername) {
            console.log('Fetching skills for provider:', selectedProviderUsername);
            fetch(`${pageContext.request.contextPath}/swaps?action=getProviderSkills&providerUsername=\${encodeURIComponent(selectedProviderUsername)}`)
                .then(response => {
                    console.log('Fetch response received. Status:', response.status);
                    if (!response.ok) {
                        console.error('Fetch response NOT OK. Status:', response.status, response.statusText);
                        return response.text().then(text => {
                           let errorMsg = `Server error ${response.status}: ${response.statusText}. `;
                           if (text) { errorMsg += `Response: ${text.substring(0,100)}`;}
                           throw new Error(errorMsg);
                        }); // This .then() is for the error case text() promise
                    }
                    return response.json();
                }) // This closes the first .then(response => ...)
                .then(skills => { // This is the .then(skills => ...) that had the missing closure
                    console.log('Skills received from server (parsed JSON):', skills);
                    skillSelect.innerHTML = '';
                    if (skills && skills.length > 0) {
                        console.log('Skills found. Populating dropdown.');
                        skillSelect.innerHTML = '<option value="">-- Select Skill --</option>';

                        skills.forEach(function(skill, index) {
                            console.log(`-----------------------------------------`);
                            console.log(`ITERATION ${index} - Skill ID: ${skill.id}`);
                            console.log('RAW skill object from JSON:', skill);

                            const option = document.createElement('option');
                            option.value = skill.id !== undefined ? String(skill.id) : `no_id_${index}`;

                            let SANE_NAME = "N/A_NAME_INIT";
                            if (skill.name !== null && skill.name !== undefined) {
                                let tempName = "";
                                for (let i = 0; i < String(skill.name).length; i++) {
                                    const charCode = String(skill.name).charCodeAt(i);
                                    if (charCode >= 32 && charCode <= 126) {
                                        tempName += String.fromCharCode(charCode);
                                    } else {
                                        console.warn(`Skipping non-standard char code ${charCode} in name for skill ID ${skill.id}`);
                                    }
                                }
                                SANE_NAME = tempName.trim();
                                if (SANE_NAME === "") SANE_NAME = "N/A_NAME_EMPTY_POST_SANITIZE";
                            } else {
                                SANE_NAME = "N/A_NAME_IS_NULL_OR_UNDEFINED";
                            }
                            console.log(`Sanitized Name: "${SANE_NAME}"`);

                            let SANE_CATEGORY = "N/A_CAT_INIT";
                            if (skill.category !== null && skill.category !== undefined) {
                                let tempCat = "";
                                for (let i = 0; i < String(skill.category).length; i++) {
                                    const charCode = String(skill.category).charCodeAt(i);
                                    if (charCode >= 32 && charCode <= 126) {
                                        tempCat += String.fromCharCode(charCode);
                                    } else {
                                        console.warn(`Skipping non-standard char code ${charCode} in category for skill ID ${skill.id}`);
                                    }
                                }
                                SANE_CATEGORY = tempCat.trim();
                                if (SANE_CATEGORY === "") SANE_CATEGORY = "N/A_CAT_EMPTY_POST_SANITIZE";
                            } else {
                                SANE_CATEGORY = "N/A_CAT_IS_NULL_OR_UNDEFINED";
                            }
                            console.log(`Sanitized Category: "${SANE_CATEGORY}"`);

                            option.textContent = SANE_NAME + " (" + SANE_CATEGORY + ")";
                            console.log(`[Option Final] Value: ${option.value}, Text: "${option.textContent}"`);

                            if ((prefillSkillId && skill.id == prefillSkillId) || (prefillSkillRequestedId && skill.id == prefillSkillRequestedId)) {
                                option.selected = true;
                            }
                            skillSelect.appendChild(option);
                        }); // End of skills.forEach

                        skillSelect.disabled = false;
                        console.log('Skill select ENABLED (with skills).');
                        skillHelpText.textContent = 'Select a skill offered by this provider.';

                    } else { // else for: if (skills && skills.length > 0)
                       console.log('No skills found or skills array is empty.');
                       skillSelect.innerHTML = '<option value="">-- No skills offered --</option>';
                       skillHelpText.textContent = 'This provider currently offers no skills.';
                       skillSelect.disabled = false;
                       console.log('Skill select ENABLED (no skills offered).');
                    }
                }) // <<<<<<<<<<< THIS IS THE CORRECTED CLOSING BRACE/PARENTHESIS for .then(skills => ...)
                .catch(error => {
                    console.error('Error in fetchAndPopulateSkills promise chain:', error);
                    skillSelect.innerHTML = '<option value="">-- Error loading skills --</option>';
                    skillHelpText.textContent = 'Could not load skills: ' + error.message;
                    skillSelect.disabled = false;
                    console.log('Skill select ENABLED (after error).');
                }); // End of .catch(...)
        } else { // else for: if (selectedProviderUsername)
            console.log('No provider selected.');
            skillSelect.innerHTML = '<option value="">-- Select Provider First --</option>';
            skillSelect.disabled = true;
            console.log('Skill select DISABLED (no provider).');
            skillHelpText.textContent = 'Select a provider to see their offered skills.';
        }
    } // End of fetchAndPopulateSkills function

    // Attach event listener
    if (providerSelect) {
       providerSelect.addEventListener('change', function() {
           console.log('Provider selection CHANGED! New value:', providerSelect.value);
           fetchAndPopulateSkills();
       });
    } else {
       console.error("CRITICAL: providerSelect element not found, cannot attach event listener.");
    }

    // Initial call on page load
    if (providerSelect && providerSelect.value && providerSelect.value !== "") {
        console.log('Initial page load - provider has value. Calling fetchAndPopulateSkills.');
        fetchAndPopulateSkills();
    } else {
        console.log('Initial page load - no provider selected.');
    }
</script>
</body>
</html>