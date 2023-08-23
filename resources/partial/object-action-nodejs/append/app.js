app.post('/sample/object/action/1', async (req, res) => {
	const json = req.body;

	logger.log(`User ${req.jwt.username} is authorized`);
	logger.log(`User scopes: ${req.jwt.scope}`);
	logger.log(`json: ${JSON.stringify(json, null, '\t')}`);

	res.status(200).send(json);
});

app.post('/sample/object/action/2', async (req, res) => {
	const json = req.body;

	logger.log(`User ${req.jwt.username} is authorized`);
	logger.log(`User scopes: ${req.jwt.scope}`);
	logger.log(`json: ${JSON.stringify(json, null, '\t')}`);

	res.status(200).send(json);
});