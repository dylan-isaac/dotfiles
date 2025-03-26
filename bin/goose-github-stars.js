// GitHub Stars Analyzer - Goose Extension
// This extension scrapes GitHub repository stars and generates thank-you messages
// Usage: goose "Analyze stars on GitHub repo {owner}/{repo}"

/**
 * @name github-stars
 * @description Scrape GitHub stars and generate thank you messages
 * @author Dylan Sheffer
 * @version 1.0.0
 */

/**
 * Main function to handle the GitHub stars analysis
 * @param {object} context - The Goose context object
 * @returns {Promise<object>} - Result object with stars data and thank you messages
 */
export default async function githubStars(context) {
  const { input, browser } = context;
  
  // Extract repository information from the input
  const repoRegex = /(?:analyze stars on github repo|analyze stars for|analyze github stars for|get stars from)\s+([a-zA-Z0-9_.-]+)\/([a-zA-Z0-9_.-]+)/i;
  const match = input.match(repoRegex);
  
  if (!match) {
    return {
      error: "Please specify a GitHub repository in the format 'owner/repo'",
      example: "Analyze stars on GitHub repo microsoft/vscode"
    };
  }
  
  const owner = match[1];
  const repo = match[2];
  
  try {
    // Initialize browser if it doesn't exist
    const page = await browser.newPage();
    
    // Navigate to the repository's stargazers page
    await page.goto(`https://github.com/${owner}/${repo}/stargazers`);
    
    // Check if repository exists
    const notFoundElement = await page.$('div.logged-out.not-found');
    if (notFoundElement) {
      await page.close();
      return {
        error: `Repository ${owner}/${repo} not found. Please check the repository name and try again.`
      };
    }
    
    // Get repository metadata
    const repoName = await page.evaluate(() => {
      const titleElement = document.querySelector('title');
      return titleElement ? titleElement.textContent.trim() : null;
    });
    
    // Get total stars count
    let totalStars = await page.evaluate(() => {
      const countElement = document.querySelector('span.Counter.js-social-count');
      return countElement ? countElement.getAttribute('title').replace(',', '') : '0';
    });
    
    totalStars = parseInt(totalStars, 10);
    
    // Scrape stargazers data
    // Note: GitHub only loads a limited number without infinite scrolling
    const stargazers = await page.evaluate(() => {
      const users = [];
      const userElements = document.querySelectorAll('h3.follow-list-name a');
      
      userElements.forEach(element => {
        const username = element.textContent.trim();
        const profileUrl = element.getAttribute('href');
        users.push({
          username,
          profileUrl: `https://github.com${profileUrl}`
        });
      });
      
      return users;
    });
    
    // Generate thank you messages
    const thankYouMessages = generateThankYouMessages(stargazers);
    
    // Close the page when done
    await page.close();
    
    // Return the results
    return {
      repository: `${owner}/${repo}`,
      repoName,
      totalStars,
      stargazersSample: stargazers,
      sampleSize: stargazers.length,
      thankYouMessages,
      note: "GitHub only displays a limited number of stargazers per page. The sample size represents only the first page."
    };
  } catch (error) {
    return {
      error: `An error occurred: ${error.message}`,
      repository: `${owner}/${repo}`
    };
  }
}

/**
 * Generate personalized thank-you messages for stargazers
 * @param {Array<object>} stargazers - List of stargazers with usernames
 * @returns {Array<object>} - List of personalized thank-you messages
 */
function generateThankYouMessages(stargazers) {
  if (!stargazers || stargazers.length === 0) {
    return [];
  }
  
  const templates = [
    `Hey @{{username}}! Thanks for starring my repository. I really appreciate your support!`,
    `@{{username}} Thank you for the star! It's great to know that you find my project interesting.`,
    `A big thank you to @{{username}} for starring my repository! Your support motivates me to continue improving it.`,
    `Thanks @{{username}} for showing interest in my project by starring it! Would love to hear your feedback.`,
    `@{{username}} Thanks for the star! It means a lot to see people interested in this project.`
  ];
  
  return stargazers.map(user => {
    const randomTemplateIndex = Math.floor(Math.random() * templates.length);
    const template = templates[randomTemplateIndex];
    const message = template.replace('{{username}}', user.username);
    
    return {
      username: user.username,
      profileUrl: user.profileUrl,
      thankYouMessage: message
    };
  });
}

// Enable MCP command registration for Goose
githubStars.mcp = {
  commands: [
    {
      name: "github-stars",
      description: "Analyze GitHub repository stars and generate thank-you messages",
      async run(input) {
        return githubStars({ input, browser: this.browser });
      }
    }
  ]
};

// Provide additional help information
githubStars.help = {
  examples: [
    "Analyze stars on GitHub repo microsoft/vscode",
    "Get stars from facebook/react",
    "Analyze GitHub stars for torvalds/linux"
  ]
}; 